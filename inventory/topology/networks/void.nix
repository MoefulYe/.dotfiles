{ inventory, inputs, ... }:
let
  inherit (inventory) hosts;
  inherit (inputs.nixpkgs) lib;
  # 1-63静态分配物理机器
  # 64-127静态分配虚拟机
  # 128-254动态分配
  # IP # shorthand for the static type
  # | { type = "dhcp"; mac = "xx:xx:xx:xx:xx:xx"; ip = "192.168.231.xxx"; }
  # | { type = "static"; ip = "192.168.231.xxx"; }
  staticMembers = {
    "zhuque" = "192.168.231.1";
    "qingloong" = "192.168.231.2";
    "lan" = "192.168.231.3";
    "mume" = {
      type = "dhcp";
      mac = "68:5e:dd:0e:99:08";
      ip = "192.168.231.5";
    };
  };
  getStaticMemberIp = ipInfo: if lib.isAttrs ipInfo then ipInfo.ip else ipInfo;
  dnsSuffix = "void";
  dnsRecords =
    (
      staticMembers
      |> lib.mapAttrsToList (
        name: ipInfo:
        let
          ip = getStaticMemberIp ipInfo;
          alias = hosts.${name}.alias or [ ];
        in
        [
          {
            type = "A";
            name = "${name}.${dnsSuffix}";
            address = ip;
          }
        ]
        ++ (
          alias
          |> lib.map (alias: {
            type = "CNAME";
            name = "${alias}.${dnsSuffix}";
            canonicalName = "${name}.${dnsSuffix}";
          })
        )
      )
      |> lib.concatLists
    )
    ++ [
      {
        type = "CNAME";
        name = "builder.nix.void";
        canonicalName = "desk00-u265kf-lan.void";
      }
    ];
in
rec {
  # 网络 子网掩码 网关 DNS 服务器 静态成员的声明
  network = "192.168.231.0";
  prefixLength = 24;
  gateway = "192.168.231.1";
  sidecarGateway = "192.168.231.2";
  dnsServer = "192.168.231.2";
  dhcpServer = "192.168.231.2";
  dhcpRange = "192.168.231.128,192.168.231.254,255.255.255.0,12h";
  inherit staticMembers dnsRecords;
  nixosConfig = {
    staticMemberNetworkdConfig =
      {
        interface,
        networkdConfigname ? "40-${interface}",
        override ? { },
        ...
      }:
      {
        hostInfo,
        ...
      }:
      let
        config = {
          networking.domain = "void";
          systemd.network.networks."${networkdConfigname}" = {
            matchConfig.Name = interface;
            networkConfig = {
              Address = [
                "${getStaticMemberIp staticMembers.${hostInfo.hostname}}/${builtins.toString prefixLength}"
              ];
              Gateway = [ sidecarGateway ];
              DNS = [ dnsServer ];
              DHCP = "no";
            };
          };
        };
      in
      {
        config = lib.recursiveUpdate config override;
      };
    dnsmasqConfig = {
      services.dnsmasq = {
        enable = true;
        settings = {
          port = 0;
          # bind-interfaces = true;
          dhcp-range = [ dhcpRange ];
          dhcp-option = [
            "option:router,${sidecarGateway}"
            "option:dns-server,${dnsServer}"
          ];
          listen-address = "${dhcpServer}";
          log-dhcp = true;
          dhcp-host =
            staticMembers
            |> lib.filterAttrs (_: info: lib.isAttrs info && info.type == "dhcp")
            |> lib.mapAttrsToList (_: { mac, ip, ... }: "${mac},${ip}");
        };
      };
      # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      networking.firewall = {
        allowedUDPPorts = [
          67
        ];
      };
    };
  };
}
