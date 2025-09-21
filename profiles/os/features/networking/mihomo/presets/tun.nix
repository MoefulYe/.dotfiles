{
  lib,
  paths,
  config,
  pkgs,
  ...
}:
let
  mkConfig = import ../helpers/mkConfig.nix;
  keywordFilters = import ../helpers/regionKeywords.nix;
  regionMatchRegs = keywordFilters.regionMatchRegs;
  otherRegionMatchReg = keywordFilters.otherRegionMatchReg;
  regions = keywordFilters.regions;
  cfg = config.services.mihomo.presets.tproxy;

  basic-config = ''
    mode: rule
    ipv6: false
    # tproxy-port: ${builtins.toString cfg.tproxyPort}
    # routing-mark: ${builtins.toString cfg.routingMark}
    allow-lan: true
    log-level: ${cfg.logLevel}
    bind-address: "*"
    unified-delay: true
    tcp-concurrent: true
    external-controller: ":9090"
    secret: ${config.sops.placeholder.MIHOMO_WEB_UI_PASSWD}
    profile:
      store-selected: true
      store-fake-ip: true
    global-client-fingerprint: random
    geodata-mode: true
    geox-url:
      geoip: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
      geosite: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
      mmdb: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb"
    tun:
      enable: true
      stack: system
      auto-route: true
      auto-detect-interface: true
      dns-hijack:
        - any:53
        - tcp://any:53

    #------------------------DNS 配置------------------------#
    dns:
      enable: true              # 启用DNS服务器
      prefer-h3: true          # 优先使用HTTP/3查询
      ipv6: false              # DNS解析IPv6
      listen: 0.0.0.0:53       # DNS监听地址
      enhanced-mode: redir-host   # DNS模式: fake-ip或redir-host
      use-hosts: true          # 使用hosts文件

      # 默认DNS服务器(用于解析其他DNS服务器的域名)
      default-nameserver:
        - 223.5.5.5            # 阿里DNS
        - 119.29.29.29         # 腾讯DNS

      # DNS服务器分流策略
      nameserver-policy:
        'www.google.com': 'https://dns.google/dns-query'      # Google域名使用Google DNS
        'www.facebook.com': 'https://dns.google/dns-query'    # Facebook域名使用Google DNS
        '.cn': 'https://doh.pub/dns-query'                    # 中国域名使用国内DNS

      # Fake-IP配置
      fake-ip-range: 198.18.0.1/16    # Fake-IP地址段
      fake-ip-filter:                 # Fake-IP过滤清单
        - "*.lan"                     # 本地域名
        - "localhost.ptlogin2.qq.com" # QQ登录

      # 主要DNS服务器
      nameserver:
        # 国内DNS服务器
        - https://doh.pub/dns-query#h3=true                # DNSPod DOH
        - https://dns.alidns.com/dns-query#h3=true         # 阿里 DOH
        - tls://223.5.5.5:853                              # 阿里 DOT

        # 国外DNS服务器
        - https://dns.google/dns-query#h3=true             # Google DOH
        - https://cloudflare-dns.com/dns-query#h3=true     # Cloudflare DOH
        - quic://dns.adguard.com:784                       # AdGuard DOQ

      # 备用DNS服务器(用于解析国外域名)
      fallback:
        - https://dns.google/dns-query#h3=true
        - https://1.1.1.1/dns-query#h3=true
        - tls://8.8.8.8:853
  '';
  proxy-providers = [
    # "ikuuu"
    "leiting"
    "mojie"
    "av1"
    # "pokemon"
  ];
  proxy-providers' = lib.attrsets.genAttrs proxy-providers (name: {
    type = "http";
    interval = 3600;
    health-check = {
      enable = true;
      url = "https://cp.cloudflare.com";
      interval = 300;
      timeout = 1000;
      tolerance = 100;
    };
    path = "./proxy-providers/${name}.yaml";
    url = config.sops.placeholder."${name}";
    override = {
      udp = true;
      additional-prefix = "[${name}] ";
    };
  });
  zju = {
    enable = cfg.zjuConnect.enable;
    proxies = [
      {
        name = "zju-connect";
        type = "socks5";
        server = "localhost";
        port = cfg.zjuConnect.socks5Port;
      }
    ];
    proxy-groups = [
      {
        name = "ZJU";
        type = "select";
        proxies = [
          "DIRECT"
          "zju-connect"
        ];
      }
    ];
    rules = [ "IP-CIDR,10.0.0.0/8,ZJU" ];
  };
  proxies = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxies)
  ];
  rule-providers = {
    anti-AD = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml";
      behavior = "domain";
    };
    anti-AD-white = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml";
      behavior = "domain";
    };
  };
  rule-providers' =
    rule-providers
    |> builtins.mapAttrs (
      name: value: with value; {
        type = "http";
        format = "yaml";
        inherit url behavior;
        path = "./rule-providers/${name}.yaml";
        interval = 3600;
      }
    );

  proxy-groups = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxy-groups)
    # 按照区域匹配的代理组
    (
      (
        regionMatchRegs
        |> (builtins.mapAttrs (
          name: filter: {
            inherit name filter;
            type = "url-test";
            use = proxy-providers;
          }
        ))
        |> builtins.attrValues
      )
      ++ [
        # 其他地区的代理组
        {
          name = "other-region";
          type = "url-test";
          use = proxy-providers;
          filter = otherRegionMatchReg;
        }
      ]
    )
    # 规则特定的代理组
    [
      {
        name = "ad-block";
        type = "select";
        proxies = [
          "REJECT"
          "DIRECT"
          "manual"
        ];
      }
      {
        name = "GOOGLE";
        type = "select";
        use = proxy-providers;
        proxies = [
          "auto-fast"
          "manual"
          "all"
          "other-region"
          "DIRECT"
        ]
        ++ regions;

      }
      {
        name = "GITHUB";
        type = "select";
        use = proxy-providers;
        proxies = [
          "auto-fast"
          "manual"
          "all"
          "other-region"
          "DIRECT"
        ]
        ++ regions;
      }
      {
        name = "AI";
        type = "select";
        use = proxy-providers;
        proxies = [
          "auto-fast"
          "manual"
          "all"
          "other-region"
          "DIRECT"
        ]
        ++ regions;
      }
    ]
    [
      {
        name = "all";
        type = "url-test";
        use = proxy-providers;
      }
      {
        name = "auto-fast";
        type = "url-test";
        use = proxy-providers;
        tolerance = 2;
      }
      {
        name = "manual";
        type = "select";
        proxies = regions ++ [
          "all"
          "auto-fast"
          "DIRECT"
        ];
      }
      {
        name = "universal";
        type = "select";
        proxies = [
          "auto-fast"
          "manual"
          "all"
          "other-region"
          "DIRECT"
        ]
        ++ regions;
      }
    ]
  ];
  rules = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.rules)
    [
      "GEOSITE,private,DIRECT,no-resolve"
      "GEOIP,private,DIRECT,no-resolve"
      "AND,((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white)))),ad-block"
      "GEOSITE,openai,AI"
      "GEOSITE,anthropic,AI"
      "GEOSITE,x,AI"
      "GEOSITE,xai,AI"
      "DOMAIN-SUFFIX,claude.ai,AI"
      "DOMAIN-SUFFIX,claudeusercontent.com,AI"
      "GEOSITE,apple,universal"
      "GEOSITE,apple-cn,universal"
      "GEOSITE,google,GOOGLE"
      "GEOSITE,ehentai,universal"
      "GEOSITE,github,GITHUB"
      "GEOSITE,twitter,universal"
      "GEOSITE,youtube,universal"
      "GEOSITE,telegram,universal"
      "GEOSITE,bahamut,universal"
      "GEOSITE,spotify,universal"
      "GEOSITE,pixiv,universal"
      "GEOSITE,steam@cn,DIRECT"
      "GEOSITE,steam,universal"
      "GEOSITE,onedrive,universal"
      "GEOSITE,microsoft,universal"
      "GEOSITE,geolocation-!cn,universal"
      # "DOMAIN-SUFFIX,bing.com,DIRECT"
      "DOMAIN-SUFFIX,gstatic.com,GOOGLE"
      "DOMAIN-SUFFIX,googleapis.com,GOOGLE"
      # quic "AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOIP,CN))),REJECT"
      "GEOIP,telegram,universal"
      "GEOIP,twitter,universal"
      "GEOSITE,CN,DIRECT"
      "GEOIP,CN,DIRECT"
      "MATCH,universal"
    ]
  ];
in
with lib;
{
  options.services.mihomo.presets.tproxy = {
    tproxyPort = mkOption {
      type = types.int;
      default = 7895;
    };
    routingMark = mkOption {
      type = types.int;
    };
    zjuConnect = {
      enable = mkEnableOption "enable zju connect proxy";
      socks5Port = mkOption {
        type = types.int;
      };
    };
    logLevel = mkOption {
      type = types.str;
      default = "info";
    };
  };
  config = {
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = config.sops.templates."mihomo.yaml".path;
      webui = pkgs.metacubexd;
    };
    sops.secrets = {
      MIHOMO_WEB_UI_PASSWD = {
        sopsFile = "${paths.secrets}/per-host/${config.osProfiles.common.hostInfo.hostname}/default.yaml";
      };
    }
    // (
      proxy-providers
      |> builtins.map (name: {
        inherit name;
        value = {
          sopsFile = "${paths.secrets}/mihomo.yaml";
        };
      })
      |> builtins.listToAttrs
    );
    sops.templates."mihomo.yaml".content = mkConfig {
      inherit
        lib
        basic-config
        proxies
        rules
        proxy-groups
        ;
      proxy-providers = proxy-providers';
      rule-providers = rule-providers';
    };
  };
}
