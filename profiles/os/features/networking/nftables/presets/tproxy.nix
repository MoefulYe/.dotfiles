# 抄自: https://evine.win/p/我的家庭网络设计思路开启debian的旁路由之路四
{
  pkgs,
  lib,
  config,
  ...
}:
let
  exposed =
    let
      cfg = config.networking.firewall;
      portsToNftSet =
        ports: portRanges:
        let
          # 检查端口是否在任何一个端口范围内
          isInRange = port: lib.any (range: port >= range.from && port <= range.to) portRanges;

          # 过滤掉落在端口范围内的单个端口
          filteredPorts = lib.filter (port: !isInRange port) ports;
        in
        lib.concatStringsSep ", " (
          map (x: toString x) filteredPorts ++ map (x: "${toString x.from}-${toString x.to}") portRanges
        );
    in
    {
      tcp = portsToNftSet cfg.allowedTCPPorts cfg.allowedTCPPortRanges;
      udp = portsToNftSet cfg.allowedUDPPorts cfg.allowedUDPPortRanges;
    };
  cfg = config.networking.nftables.presets.tproxy;
in
{
  options.networking.nftables.presets.tproxy = with lib; {
    tproxyPort = mkOption {
      type = types.int;
    };
    proxyFwMark = mkOption {
      type = types.int;
    };
    outbounds = mkOption {
      type = types.listOf types.str;
    };
    routeToProxyMark = mkOption {
      type = types.int;
      default = 1;
    };
    networkdUnitName = mkOption {
      type = types.str;
      default = "50-tproxy";
    };
  };
  config = {
    networking.firewall.enable = false;
    systemd.network.networks."${cfg.networkdUnitName}" = {
      name = "lo";
      routes = [
        {
          Scope = "host";
          Table = 100;
          Destination = "0.0.0.0/0";
        }
      ];
      routingPolicyRules = [
        {
          Family = "both";
          FirewallMark = builtins.toString cfg.routeToProxyMark;
          Priority = 10;
          Table = 100;
        }
      ];
    };
    networking = {
      nftables = {
        enable = true;
        checkRuleset = false;
        flushRuleset = true;
      };
      nftables.tables."sys-fw" = {
        enable = true;
        family = "inet";
        # 添加dns劫持
        content = ''
            set exposed-tcp-ports {
              type inet_service
          	  flags interval
              elements = { ${exposed.tcp} }
            }

            set exposed-udp-ports {
              type inet_service
          	  flags interval
              elements = { ${exposed.udp} }
            }

            set outbounds {
              type iface_index
              elements = { ${builtins.concatStringsSep "," cfg.outbounds} }
            }


            set private_addrs {
              type ipv4_addr
              flags interval
              elements = {
                127.0.0.0/8,
                100.64.0.0/10,
                169.254.0.0/16,
                224.0.0.0/4,
                240.0.0.0/4,
                10.0.0.0/8,
                172.16.0.0/12,
                192.168.0.0/16
              }
            }


            chain prerouting {
          	 	type filter hook prerouting priority filter; policy accept;
              udp sport . udp dport { 68 . 67, 67 . 68 } accept comment "DHCPv4 client/server"
              # fib saddr . mark oif exists goto mihomo-prerouting
              # jump rpfilter-allow
              goto mihomo-prerouting
          	}

            chain rpfilter-allow {}
            chain mihomo-prerouting {
              meta l4proto { tcp, udp } socket transparent 1 meta mark set ${builtins.toString cfg.routeToProxyMark} accept # 绕过已经建立的连接
              meta mark ${builtins.toString cfg.routeToProxyMark} goto mihomo-tproxy                               # 已经打上default_mark标记的属于本机流量转过来的，直接进入透明代理
            	tcp dport @exposed-tcp-ports accept
          	 	udp dport @exposed-udp-ports accept
              fib daddr type { local, broadcast, anycast, multicast } accept                   # 绕过本地、单播、组播、多播地址
              tcp dport { 53 } accept                                                # 绕过经由本机到目标端口的tcp流量
              udp dport { 53, 123 } accept
              ip daddr @private_addrs accept                                             # 绕过目标地址为保留ip的地址
              goto mihomo-tproxy                                                                # 其他流量透明代理到clash
            }


            chain input {
              type filter hook input priority filter; policy accept;
            }
            # chain input {
          	#   type filter hook input priority filter; policy drop;
            #   allow
          	#   iifname "lo" accept comment "trusted interfaces"
          	#   ct state vmap { invalid : drop, established : accept, related : accept, new : jump input-allow, untracked : jump input-allow }
          	#   tcp flags & (fin | syn | rst | ack) == syn log prefix "refused connection: " level info
          	# }


          	# chain input-allow {
            # 	tcp dport @exposed-tcp-ports accept
          	#  	udp dport @exposed-udp-ports accept
          	#  	icmp type echo-request accept comment "allow ping"
          	#  	icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
          	#  	ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"
          	# }


            chain output {
              type route hook output priority filter; policy accept;
              oif != @outbounds accept                                   # 绕过本机内部通信的流量（接口lo）
              meta mark ${builtins.toString cfg.proxyFwMark} accept                                   # 绕过本机clash发出的流量
              fib daddr type { local, broadcast, anycast, multicast } accept # 绕过本地、单播、组播、多播地址
              udp dport { 53, 123 } accept                                   # 绕过本机dns查询、NTP流量
              tcp sport @exposed-tcp-ports accept                               
              udp sport @exposed-udp-ports accept
              ip daddr @private_addrs accept                           # 绕过目标地址为保留ip的地址
              meta l4proto { tcp, udp } meta mark set ${builtins.toString cfg.routeToProxyMark} # 其他流量重路由到prerouting
            }


            chain mihomo-tproxy {
              meta l4proto {tcp, udp} tproxy to :${builtins.toString cfg.tproxyPort} meta mark set ${builtins.toString cfg.routeToProxyMark} accept
            }
        '';
      };
    };
  };
}
