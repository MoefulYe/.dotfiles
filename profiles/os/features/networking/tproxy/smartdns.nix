{ config, lib, pkgs, ... }: let 
  # TODO enable ANTIAD
  cfg = config.osProfiles.features.tproxy.smartdns;
  mihomoSocks5Port = config.osProfiles.features.tproxy.mihomo.socks5Port;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;

  configFile = pkgs.writeText "smartdns.conf" ''
    # optional use this conf file
    # conf-file /var/lib/smartdns/anti-ad-smartdns.conf
    force-AAAA-SOA yes
    proxy-server socks5://127.0.0.1:${builtins.toString mihomoSocks5Port} -name socks5
    
    group-begin domestic-dns
       # 阿里云
       server 223.5.5.5 -exclude-default-group -bootstrap-dns
       server 223.6.6.6 -exclude-default-group -bootstrap-dns
       # 腾讯云
       server 119.29.29.29 -exclude-default-group -bootstrap-dns
    group-end
    
    group-begin foreign-doh
       server-https https://cloudflare-dns.com/dns-query -exclude-default-group -proxy socks5
       server-https https://dns.google/dns-query -exclude-default-group -proxy socks5
       server-https https://doh.opendns.com/dns-query -exclude-default-group -proxy socks5
       server-https https://dns.quad9.net/dns-query -exclude-default-group -proxy socks5
       server-https https://doh.dns.sb/dns-query -exclude-default-group -proxy socks5
       server-https https://doh.mullvad.net/dns-query -exclude-default-group -proxy socks5
       server-https https://dns.adguard-dns.com/dns-query -exclude-default-group -proxy socks5
       server-https https://dns-family.adguard.com/dns-query -exclude-default-group -proxy socks5
       server-https https://freedns.controld.com/p0 -exclude-default-group -proxy socks5
       server-https https://dns.nextdns.io -exclude-default-group -proxy socks5
    group-end
    
    # hardcodedHosts
    address /cloudflare-dns.com/1.1.1.1,1.0.0.1
    address /dns.google/8.8.8.8,8.8.4.4
    
    # 国内DNS解析与代理节点DNS解析
    bind [::]:${builtins.toString cfg.domesticDnsPort} -group domestic-dns
    bind [::]:${builtins.toString cfg.foreignDnsPort} -group foreign-doh
    ${cfg.extraSettings}
  '';
in {
  services.resolved.enable = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
  systemd.services."my-smartdns" = {
    enable = true; 
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.smartdns}/bin/smartdns -f -c ${configFile} -p -";
      User = tproxyBypassUser;
      Group = tproxyBypassUser;
      StateDirectory = "smartdns";
      LogsDirectory= "smartdns";
      CacheDirectory = "smartdns";
      AmbientCapabilities="CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet="CAP_NET_BIND_SERVICE";
    };
  };
  environment.etc."resolv.conf".text = ''
    nameserver 119.29.29.29
  '';
}