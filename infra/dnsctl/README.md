# infra/dnsctl

`infra/dnsctl` 是一个给 NixOS 主机做“DNS 暴露建模”的桩模块。

它的目标不是直接同步 DNS，而是把每台机器对外暴露的信息先沉淀到 NixOS module 里，再由 `collector.nix` 从所有 `nixosConfigurations` 中汇总成 `nixdnsctl` 的 DSL。

## 解决的问题

在没有这个模块时，下面几类信息通常散落在不同位置：

- `networking.hostName` / `alias`
- 主机的 `ipv4` / `ipv6`
- `services.nginx.virtualHosts`
- `nixdnsctl` 需要的 DNS records

这样很容易出现：

- nginx 已经配置了，但 DNS 没配
- DNS 还在，但服务已经删掉
- 主机域名、别名、站点域名重复维护

这个模块把这些“对外暴露信息”收敛到 `infra` 层，然后自动导出为 DNS 记录。

## 组成

- `default.nix`
  - NixOS 模块入口
  - 定义 `infra` 下的 DNS 相关选项
  - 把 `infra.nginxVirtualHosts` 转发到 `services.nginx.virtualHosts`
  - 生成当前主机的 `config.infra.dnsctl.records`
- `collector.nix`
  - 从所有 `nixosConfigurations.<name>.config.infra.dnsctl.records` 收集记录
  - 合并同名记录
  - 组装成 `nixdnsctl` 需要的 `{ providers; zones; }` DSL

## 设计原则

- 主机名与 alias 是基础设施标识，默认 `proxied = false`
- nginx 暴露的站点是应用入口，默认 `proxied = true`
- 站点记录允许通过 `dnsRecordExt` 注入额外字段，并覆盖默认字段
- `infra.nginxVirtualHosts` 只接受：
  - `@`
  - 相对名，例如 `blog`、`api`、`a.b`
- 不接受：
  - 完整 FQDN，例如 `blog.example.com`
  - regex server name，例如 `~^foo.*`

## 选项

### `infra.ipv4`

类型：`null | str | [ str ]`

当前主机用于导出 DNS 的 IPv4 地址。

### `infra.ipv6`

类型：`null | str | [ str ]`

当前主机用于导出 DNS 的 IPv6 地址。

### `infra.dnsctl.domain`

类型：`null | str`

DNS 主域名来源。

当前模块会让：

- `networking.domain` 默认继承 `infra.dnsctl.domain`

也就是说通常只需要设置 `infra.dnsctl.domain`。

### `infra.dnsctl.extraRecords`

类型：`[ attrs ]`

允许用户额外注入记录。

这类记录会直接并入最终导出的 `infra.dnsctl.records`，再由 `collector.nix` 汇总到 flake 顶层 `dnsctl`。

适合放：

- 不是 nginx 派生出的记录
- 特殊的 `A` / `AAAA` / `CNAME`
- `TXT` / `MX` / `SRV` 一类记录
- 需要自定义 `ttl`、`comment`、`proxied` 等字段的记录

记录至少应包含：

- `name`
- `type`
- `values`

其中 zone 默认就是当前主机的 `infra.dnsctl.domain`。

同时也允许注入 provider-specific 扩展字段。

### `infra.nginxVirtualHosts`

类型：基于 `services.nginx.virtualHosts` 扩展出的 attrset。

它和原始 nginx virtual host 配置基本一致，但额外支持一个字段：

- `dnsRecordExt`

`dnsRecordExt` 不会转发给 nginx，只会注入到导出的 DNS record 中。

可用于：

- 覆盖默认 `proxied = true`
- 增加 `ttl`
- 增加 `comment`
- 传递 provider-specific 字段

## 导出规则

假设：

- `networking.hostName = "citrus"`
- `infra.dnsctl.domain = "example.com"`
- `hostInfo.alias = [ "vps00" ]`
- `infra.ipv4 = "1.2.3.4"`

那么会导出：

- `citrus.example.com` -> `A` / `AAAA`，默认 `proxied = false`
- `vps00.example.com` -> `CNAME citrus.example.com`，默认 `proxied = false`

对于 nginx 站点：

- `infra.nginxVirtualHosts."@"` -> nginx key `example.com`
- `infra.nginxVirtualHosts.blog` -> nginx key `blog.example.com`
- `infra.nginxVirtualHosts.api.admin` -> nginx key `api.admin.example.com`

对应 DNS 导出：

- `@` -> apex 记录
- `blog` -> `blog.example.com`
- `api.admin` -> `api.admin.example.com`

默认：

- nginx 站点记录 `proxied = true`

但可以用 `dnsRecordExt` 覆盖：

```nix
infra.nginxVirtualHosts.api = {
  dnsRecordExt = {
    proxied = false;
    ttl = 120;
    comment = "origin endpoint";
  };

  locations."/" = {
    proxyPass = "http://127.0.0.1:9000";
  };
};
```

如果需要额外手工注入记录，可以写：

```nix
infra.dnsctl.extraRecords = [
  {
    name = "derp";
    type = "A";
    values = [ "1.2.3.4" ];
    proxied = false;
    comment = "manual infra endpoint";
  }
  {
    name = "_acme-challenge";
    type = "TXT";
    values = [ "challenge-token" ];
  }
];
```

## 使用示例

```nix
{
  networking.hostName = "citrus";

  infra = {
    ipv4 = "1.2.3.4";
    ipv6 = null;

    dnsctl.domain = "example.com";
    dnsctl.extraRecords = [
      {
        name = "derp";
        type = "A";
        values = [ "1.2.3.4" ];
        proxied = false;
      }
    ];

    nginxVirtualHosts = {
      "@" = {
        forceSSL = true;
        enableACME = true;
        dnsRecordExt = {
          proxied = false;
          comment = "apex";
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
        };
      };

      blog = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/blog";
      };

      api = {
        dnsRecordExt.ttl = 120;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9000";
        };
      };
    };
  };
}
```

## collector 如何使用

这个模块的 collector 不是在 host 里手动调用的。

它的接入方式是：

1. `helpers/mkNixosConfigs.nix` 把 `infra/dnsctl` 自动注入到每个 NixOS host
2. 每台 host 在模块求值后生成 `config.infra.dnsctl.records`
3. `flake.nix` 调用 `infra/dnsctl/collector.nix`
4. collector 汇总所有 host 的 records，生成 flake 顶层 `dnsctl`

因此最终可以把：

- `.#dnsctl`

直接作为 `nixdnsctl` 的输入。

如果需要在 collector 侧为不同 zone 指定不同 provider，可以在调用时传：

```nix
dnsctl = collectDnsctl {
  inherit nixosConfigurations;

  providers = {
    cf-prod = {
      type = "cloudflare";
      tokenFile = "/run/secrets/cf-prod-token";
    };
    cf-lab = {
      type = "cloudflare";
      tokenFile = "/run/secrets/cf-lab-token";
    };
  };

  zoneProviders = {
    "example.com" = "cf-prod";
    "lab.example.com" = "cf-lab";
    "059867.xyz" = "cf-prod";
  };

  extraRecords = {
    "example.com" = [
      {
        name = "pages";
        type = "CNAME";
        values = [ "my-project.pages.dev" ];
        proxied = true;
      }
      {
        name = "_dmarc";
        type = "TXT";
        values = [ "v=DMARC1; p=quarantine" ];
      }
    ];
  };

  defaultProvider = "cf-prod";
};
```

规则是：

- 某个 zone 在 `zoneProviders` 里命中时，使用对应 provider
- 否则回退到 `defaultProvider`
- `extraRecords` 会在 collector 阶段直接并入最终 records，格式是 `{ "zone" = [ { ... } ]; }`

## 当前边界

当前原型主要负责：

- host / alias / nginx virtualHosts -> DNS record 的导出
- 多 host records 汇总
- 输出 `nixdnsctl` DSL 形状

当前没有在这个模块里处理：

- provider secrets 的分发
- 更高层的部署流程

这些可以后续继续叠加在 `collector.nix` 或 flake 输出层上。
