{ inventory, lib, ... }:
let
  inherit (inventory) hosts;
  # 1-63静态分配物理机器
  # 64-127静态分配虚拟机
  # 128-254动态分配
  # IP # shorthand for the static type
  # | { type = "dhcp"; mac = "xx:xx:xx:xx:xx:xx"; ip = "192.168.231.xxx"; }
  # | { type = "static"; ip = "192.168.231.xxx"; }
  staticMembers = {
    "rutr00-k2p-zhuque" = "192.168.231.1";
    "rutr01-n1-qingloong" = "192.168.231.2";
    "desk00-u265kf-lan" = "192.168.231.3";
    "lap00-xiaoxin-mei" = "192.168.231.4";
    "lap01-macm4-mume" = {
      type = "dhcp";
      mac = "d4:ae:52:1c:bb:6c";
      ip = "192.168.231.5";
    };
    "nas00-8100t-xuanwu" = "192.168.231.6";
  };
  getStaticMemberIp = ipInfo: if lib.isAttrs ipInfo then ipInfo.ip else ipInfo;
  dnsSuffix = "void";
  dnsRecords =
    staticMembers
    |> lib.mapAttrsToList (
      name: ipInfo:
      let
        ip = getStaticMemberIp ipInfo;
        aliases = hosts.${name}.aliases or [ ];
      in
      [
        {
          type = "A";
          name = "${name}.${dnsSuffix}";
          address = ip;
        }
      ]
      ++ (
        aliases
        |> lib.map (alias: {
          type = "CNAME";
          name = "${alias}.${dnsSuffix}";
          canonicalName = "${name}.${dnsSuffix}";
        })
      )
    )
    |> lib.concatLists;
  smartdnsRecords =
    dnsRecords
    |> lib.map (
      record:
      if record.type == "A" then
        "address /${record.name}/${record.address}"
      else if record.type == "CNAME" then
        "cname /${record.name}/${record.canonicalName}"
      else
        throw "Unknown record type: ${record.type}"
    )
    |> lib.concatStringsSep "\n";
in
rec {
  # 网络 子网掩码 网关 DNS 服务器 静态成员的声明
  network = "192.168.231.0";
  prefixLength = 24;
  gateway = "192.168.231.1";
  sidecarGateway = "192.168.231.3";
  dnsServer = "192.168.231.3";
  dhcpServer = "192.168.231.3";
  dhcpRange = "192.168.231.128,192.168.231.254,255.255.255.0,12h";
  inherit staticMembers dnsRecords smartdnsRecords;
  nixosConfig = {
    staticMemberNetworkdConfig =
      {
        interface,
        override,
        ...
      }:
      {
        hostInfo,
        ...
      }:
      let
        config = {
          networking.interfaces.${interface} = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = getStaticMemberIp staticMembers.${hostInfo.hostname};
                prefixLength = prefixLength;
              }
            ];
          };
          networking.defaultGateway = {
            address = sidecarGateway; # 默认指向旁路由网关
            interface = interface;
          };
          networking.nameservers = [ dnsServer ];
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
          bind-interfaces = true;
          dhcp-range = [ dhcpRange ];
          dhcp-option = [
            "option:router,${sidecarGateway}"
            "option:dns-server,${dnsServer}"
          ];
          listen-address = "${dhcpServer}";
          log-dhcp = true;
          # dhcp-host =
          #   staticMembers
          #   |> lib.filterAttrs (_: info: info.type == "dhcp")
          #   |> lib.mapAttrsToList (_: { mac, ip }: "${mac},${ip}");
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
