{ writeText, cfg, mihomoCfg, tproxyBypassUser, ... }: writeText "mihomo-tproxy.nft" ''
  table inet mihomo-tproxy {
    define TPROXY_MARK=${builtins.toString cfg.tproxyMark}
    define MIHOMO_TPROXY_PORT=${builtins.toString mihomoCfg.tproxyPort}
    define MIHOMO_DNS_PORT=${builtins.toString mihomoCfg.dnsPort}
    define BYPASS_USER=${tproxyBypassUser}
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

    include /var/lib/${cfg.chinaIpListDirname}/${cfg.chinaIPListBasename}
    
    chain mark-prerouting {
      type filter hook prerouting priority mangle; policy accept;
      meta l4proto { tcp, udp } socket transparent 1 mark set $TPROXY_MARK return comment "mark already proxied traffic"
      socket transparent 0 socket wildcard 0 return comment "bypass non-transparent sockets"
      ip daddr @bypass-ipv4 return comment "bypass special IPv4 addresses"
      ip6 daddr @bypass-ipv6 return comment "bypass special IPv6 addresses"
      tcp dport @bypass-tcp-ports return comment "bypass special ports"
      udp dport @bypass-udp-ports return comment "bypass special ports"
      fib daddr type { local, broadcast, anycast, multicast } return comment "bypass local/broadcast/multicast addresses"
      ip daddr @${cfg.chinaIpV4Set} return comment "bypass China IPv4 addresses"
      ip6 daddr @${cfg.chinaIpV6Set} return comment "bypass China IPv6 addresses"
      meta l4proto { tcp, udp } tproxy to :$MIHOMO_TPROXY_PORT meta mark set $TPROXY_MARK return comment "redirect to tproxy port"
    }            
    chain mark-output {
      type route hook output priority mangle; policy accept;
      oif != @outbounds return comment "bypass internal traffic"
      meta skuid $BYPASS_USER return comment "bypass mihomo and resolved traffic to prevent loops"
      ip daddr @bypass-ipv4 return comment "bypass special IPv4 addresses"
      ip6 daddr @bypass-ipv6 return comment "bypass special IPv6 addresses"
      tcp dport @bypass-tcp-ports return comment "bypass special ports"
      udp dport @bypass-udp-ports return comment "bypass special ports"
      fib daddr type { local, broadcast, anycast, multicast } return comment "bypass local/broadcast/multicast addresses"
      ip daddr @${cfg.chinaIpV4Set} return comment "bypass China IPv4 addresses"
      ip6 daddr @${cfg.chinaIpV6Set} return comment "bypass China IPv6 addresses"
      meta l4proto { tcp, udp } meta mark set $TPROXY_MARK return comment "mark traffic for routing to prerouting chain"
    }
    
    chain redirect-dns {
      type nat hook output priority dstnat; policy accept;
      meta skuid $BYPASS_USER return comment "bypass mihomo and resolved dns request to prevent loops"
      tcp dport 53 redirect to :$MIHOMO_DNS_PORT comment "redirect outgoing DNS to mihomo"
      udp dport 53 redirect to :$MIHOMO_DNS_PORT comment "redirect outgoing DNS to mihomo"
    }
  }
''