{ config, lib, ... }:
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
in
{
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    checkRuleset = false;
    flushRuleset = true;
    tables."sys-fw" = {
      enable = true;
      family = "inet";
      content = ''
        set temp-ports {
                type inet_proto . inet_service
                flags interval
                comment "Temporarily opened ports"
        }
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

        # chain rpfilter {
        #         type filter hook prerouting priority mangle + 10; policy drop;
        #         meta nfproto ipv4 udp sport . udp dport { 68 . 67, 67 . 68 } accept comment "DHCPv4 client/server"
        #         fib saddr . mark . iif check exists accept
        #         jump rpfilter-allow
        # }

        # chain rpfilter-allow {
        # }

        chain input {
                type filter hook input priority filter; policy drop;
                iif "lo" accept comment "trusted interfaces"
                ct state vmap { invalid : drop, established : accept, related : accept, new : jump input-allow, untracked : jump input-allow }
                tcp flags & (fin | syn | rst | ack) == syn log prefix "refused connection: " level info
        }

        chain input-allow {
                tcp dport @exposed-tcp-ports accept
                udp dport @exposed-udp-ports accept
                meta l4proto . th dport @temp-ports accept
                icmp type echo-request accept comment "allow ping"
                icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
                ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"
        }
      '';
    };
  };
}
