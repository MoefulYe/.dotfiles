{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.osProfiles.features.tproxy.smartdns;
  mihomoSocks5Port = config.osProfiles.features.tproxy.mihomo.socks5Port;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;
  antiAdFilePath = "/var/lib/smartdns/anti-ad-smartdns.conf";
  antiAdUrl = "https://anti-ad.net/anti-ad-for-smartdns.conf";
  domesticDns = [
    "223.5.5.5"
    "223.6.6.6"
    "119.29.29.29"
  ];
  foreignDoh = [
    "https://cloudflare-dns.com/dns-query"
    "https://dns.google/dns-query"
    "https://doh.opendns.com/dns-query"
    "https://dns.quad9.net/dns-query"
    # "https://doh.dns.sb/dns-query"
    "https://doh.mullvad.net/dns-query"
    "https://dns.adguard-dns.com/dns-query"
    "https://dns-family.adguard.com/dns-query"
    "https://freedns.controld.com/p0"
    "https://dns.nextdns.io"
  ];
  hardcodedHosts = {
    "cloudflare-dns.com" = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    "dns.google" = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
  configText =
    [
      ''
        force-AAAA-SOA yes
        proxy-server socks5://127.0.0.1:${builtins.toString mihomoSocks5Port} -name socks5

        group-begin domestic-dns
        ${lib.concatStringsSep "\n" (
          lib.map (dns: "server ${dns} -exclude-default-group -bootstrap-dns") domesticDns
        )}
        group-end

        group-begin foreign-doh
        ${lib.concatStringsSep "\n" (
          lib.map (doh: "server-https ${doh} -exclude-default-group -proxy socks5") foreignDoh
        )}
        group-end

        # hardcodedHosts
        ${lib.concatStringsSep "\n" (
          lib.attrValues (
            lib.mapAttrs (host: ip: ''
              address /${host}/${if lib.isString ip then ip else lib.concatStringsSep "," ip}
            '') hardcodedHosts
          )
        )}
        # 国内DNS解析与代理节点DNS解析
        bind [::]:${builtins.toString cfg.domesticDnsPort} -group domestic-dns
        bind [::]:${builtins.toString cfg.foreignDnsPort} -group foreign-doh
      ''
      cfg.extraSettings
      (lib.optionalString cfg.enableAntiAD ''
        conf-file ${antiAdFilePath}
      '')
    ]
    |> lib.concatStringsSep "\n";
  configFile = pkgs.writeText "smartdns.conf" configText;
  inherit (pkgs) my-pkgs;
  smartdnsReloader = pkgs.writeShellScript "smartdns-reloader" ''
    #!${pkgs.bash}/bin/bash
    if ${pkgs.systemd}/bin/systemctl --quiet is-active my-smartdns.service; then 
      ${pkgs.systemd}/bin/systemctl restart my-smartdns.service
    fi
  '';
  antiAdDownloader = pkgs.writeShellScript "anti-ad-downloader" ''
    export PATH=$PATH:${pkgs.gawk}/bin
    readonly DEST_TMP=$(mktemp ${antiAdFilePath}.XXXXXX)
    if ${lib.getExe my-pkgs.downloader} ${antiAdUrl} \
      --socks5 socks5://127.0.0.1:${builtins.toString mihomoSocks5Port} \
      --quiet \
      | awk '/^[[:space:]]#/ {next} /^[[:space:]]$/ {next} { sub(/#[[:space:]]*$/, "0.0.0.0"); print }' \
      > $DEST_TMP; then
      mv -f $DEST_TMP ${antiAdFilePath}
    else
      rm -f $DEST_TMP
      exit 1
    fi
  '';
  ensureAntiAdExist = "${lib.getExe my-pkgs.ensure-exist} ${antiAdFilePath} ${antiAdDownloader}";
in
{
  services.resolved.enable = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];
  systemd.services."my-smartdns" = {
    enable = true;
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.smartdns}/bin/smartdns -f -c ${configFile} -p -";
      ExecStartPre = lib.mkIf cfg.enableAntiAD ensureAntiAdExist;
      Environment = [
        "PATH=${pkgs.gzip}/bin:${pkgs.gawk}/bin"
      ];
      User = tproxyBypassUser;
      Group = tproxyBypassUser;
      StateDirectory = "smartdns";
      LogsDirectory = "smartdns";
      CacheDirectory = "smartdns";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };
  };
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver 119.29.29.29
  '';
  systemd.services."anti-ad-updater" = {
    enable = cfg.enableAntiAD;
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = antiAdDownloader;
      User = tproxyBypassUser;
      Group = tproxyBypassUser;
    };
  };
  systemd.timers."anti-ad-updater" = {
    enable = cfg.enableAntiAD;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = cfg.antiAdUpdateSchedule;
      RandomizedDelaySec = "15min";
      Persistent = false;
    };
  };
  systemd.services."smartdns-reloader" = {
    enable = cfg.enableAntiAD;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${smartdnsReloader}";
    };
  };
  systemd.paths."smartdns-reloader" = {
    enable = cfg.enableAntiAD;
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = antiAdFilePath;
      Unit = "smartdns-reloader.service";
    };
  };
}
