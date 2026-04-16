{ inputs, paths, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
rec {
  # 网络 子网掩码 网关 DNS 服务器 静态成员的声明
  network = "192.168.231.0";
  prefixLength = 24;
  gateway = "192.168.231.1";
  dhcpRange = "192.168.231.128,192.168.231.254,255.255.255.0,12h";
  nixosConfig = {
    default =
      {
        interface,
        networkdConfigname ? "40-${interface}",
        override ? { },
        address,
        ...
      }:
      let
        config = {
          infra.dnsctl.nginxVirtualHostsProxied = false;
          infra.dnsctl.nginxVirtualHostsUseSSL = false;
          infra.dnsctl.ipv4 = address;
          systemd.network.networks."${networkdConfigname}" = {
            matchConfig.Name = interface;
            networkConfig = {
              Address = [
                "${address}/${builtins.toString prefixLength}"
              ];
              Gateway = [ gateway ];
              DNS = [ gateway ];
              DHCP = "no";
            };
          };
        };
      in
      {
        imports = [
          "${paths.infra}/dnsctl"
        ];
        config = lib.recursiveUpdate config override;
      };
    gateway =
      {
        lanInterface,
        networkdConfigname ? "40-${lanInterface}",
        override ? { },
        lanAddress,
        ...
      }:
      let
        config = {
          infra.dnsctl.nginxVirtualHostsProxied = false;
          infra.dnsctl.nginxVirtualHostsUseSSL = false;
          # infra.dnsctl.ipv4 = address;  网关手动配置域名映射
          systemd.network.networks."${networkdConfigname}" = {
            matchConfig.Name = lanInterface;
            networkConfig = {
              Address = [
                "${lanAddress}/${builtins.toString prefixLength}"
              ];
              DNS = [ gateway ];
              DHCP = "no";
            };
          };
          services.dnsmasq = {
            enable = true;
            settings = {
              port = 0;
              # bind-interfaces = true;
              dhcp-range = [ dhcpRange ];
              dhcp-option = [
                "option:router,${gateway}"
                "option:dns-server,${gateway}"
              ];
              listen-address = "${gateway}";
              log-dhcp = true;
            };
          };
          networking.firewall = {
            allowedUDPPorts = [
              67
            ];
          };
        };
      in
      {
        imports = [
          "${paths.infra}/dnsctl"
        ];
        config = lib.recursiveUpdate config override;
      };
  };
}
