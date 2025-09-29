{ config, lib, ... }:
let
  cfg = config.networking.nftables.presets.tproxy-v2;
in
{
  options.networking.nftables.presets.tproxy-v2-zju = with lib; {
    tproxyPort = mkOption {
      type = types.int;
    };
    dnsPort = mkOption {
      type = types.int;
    };
    tproxyMark = mkOption {
      type = types.int;
      default = 1;
    };
    outbounds = mkOption {
      type = types.listOf types.str;
    };
    networkdUnitName = mkOption {
      type = types.str;
      default = "50-tproxy";
    };
  };
  config = {
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
          FirewallMark = builtins.toString cfg.tproxyMark;
          Priority = 10;
          Table = 100;
        }
      ];
    };
    networking.nftables = {
      enable = true;
      checkRuleset = false;
      flushRuleset = true;
      tables."mihomo-tproxy" = {
        enable = true;
        family = "inet";
        content = ''
          define TPROXY_MARK=${builtins.toString cfg.tproxyMark}
          define MIHOMO_TPROXY_PORT=${builtins.toString cfg.tproxyPort}
          define MIHOMO_DNS_PORT=${builtins.toString cfg.dnsPort}
          set bypass-ipv4 {
            type ipv4_addr
            flags interval
            elements = {
              0.0.0.0/8,
              10.0.0.0/8,
              100.64.0.0/10,
              127.0.0.0/8,
              169.254.0.0/16,
              172.16.0.0/12,
              192.168.0.0/16,
              224.0.0.0/4,
              240.0.0.0/4
            }
          }
          set bypass-ipv6 {
            type ipv6_addr
            flags interval
            elements = {
              ::/128,
              ::1/128,
              fc00::/7,
              fe80::/10,
              ff00::/8
            }
          }
          set bypass-tcp-ports {
            type inet_service
            elements = { 53, 67, 68, 123 }
          }
          set bypass-udp-ports {
            type inet_service
            elements = { 53, 67, 68, 123 }
          }
          set outbounds {
            type iface_index
            elements = { ${builtins.concatStringsSep "," cfg.outbounds} }
          }
          set bypass-users {
            type uid
            elements = { mihomo, systemd-resolve, zju-connect }
          }

          chain mark-prerouting {
            type filter hook prerouting priority mangle; policy accept;
            meta l4proto { tcp, udp } socket transparent 1 mark set $TPROXY_MARK return comment "mark already proxied traffic"
            socket transparent 0 socket wildcard 0 return comment "bypass non-transparent sockets"
            ip daddr @bypass-ipv4 return comment "bypass special IPv4 addresses"
            ip6 daddr @bypass-ipv6 return comment "bypass special IPv6 addresses"
            tcp dport @bypass-tcp-ports return comment "bypass special ports"
            udp dport @bypass-udp-ports return comment "bypass special ports"
            fib daddr type { local, broadcast, anycast, multicast } return comment "bypass local/broadcast/multicast addresses"
            meta l4proto { tcp, udp } tproxy to :$MIHOMO_TPROXY_PORT meta mark set $TPROXY_MARK return comment "redirect to tproxy port"
          }            
          chain mark-output {
            type route hook output priority mangle; policy accept;
            oif != @outbounds return comment "bypass internal traffic"
            meta skuid @bypass-users return comment "bypass mihomo and resolved traffic to prevent loops"
            ip daddr 10.0.0.0/8 meta mark set ${builtins.toString cfg.tproxyMark} accept
            ip daddr @bypass-ipv4 return comment "bypass special IPv4 addresses"
            ip6 daddr @bypass-ipv6 return comment "bypass special IPv6 addresses"
            tcp dport @bypass-tcp-ports return comment "bypass special ports"
            udp dport @bypass-udp-ports return comment "bypass special ports"
            fib daddr type { local, broadcast, anycast, multicast } return comment "bypass local/broadcast/multicast addresses"
            meta l4proto { tcp, udp } meta mark set $TPROXY_MARK return comment "mark traffic for routing to prerouting chain"
          }

          chain redirect-dns {
            type nat hook output priority dstnat; policy accept;
            meta skuid @bypass-users return comment "bypass mihomo and resolved dns request to prevent loops"
            tcp dport 53 redirect to :$MIHOMO_DNS_PORT comment "redirect outgoing DNS to mihomo"
            udp dport 53 redirect to :$MIHOMO_DNS_PORT comment "redirect outgoing DNS to mihomo"
          }
        '';
      };
    };
  };
}
