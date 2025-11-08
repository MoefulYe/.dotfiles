{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.osProfiles.features.tproxy.nftables;
  mihomoCfg = config.osProfiles.features.tproxy.mihomo;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;
  listPath = "/var/lib/${cfg.chinaIpListDirname}/${cfg.chinaIPListBasename}";
  v4Primary = "https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt";
  v6Primary = "https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt";
  v4Mirror = "https://hub.gitmirror.com/https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt";
  v6Mirror = "https://hub.gitmirror.com/https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt";
  table = pkgs.callPackage ./table.nix {
    inherit
      config
      mihomoCfg
      tproxyBypassUser
      cfg
      ;
  };
  chinaIpUpdater = pkgs.callPackage ./china-ip-updater.nix {
    inherit cfg;
    downloader = pkgs.callPackage ../../../../../../../packages/downloader { };
  };
  mihomoNftablesCtl = pkgs.callPackage ./mihomo-nftables-ctl.nix {
    inherit table cfg;
    inherit (pkgs) nftables coreutils gnugrep;
    inherit ensureExist chinaIpUpdater;
  };
in
{
  networking.nftables.enable = true;
  systemd = {
    services."my-mihomo".serviceConfig =
      let
        inherit (pkgs) my-pkgs;
        downloadIplist = "";
        ensureChinaIplistExist = "${lib.getExe my-pkgs.ensure-exist} ${listPath} ";
      in
      {
        StateDirectory = [
          cfg.chinaIpListDirname
        ];
        PermissionsStartOnly = true;
        ExecStartPre = [
          ""
        ];
        ExecStopPost = [ "+${mihomoNftablesCtl} down" ];
      };
    services."china-ip-updater" = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${chinaIpUpdater} --dest ${listPath} --v4 ${v4Primary} --v4-fallback ${v4Mirror} --v6 ${v6Primary} --v6-fallback ${v6Mirror} --set-v4 ${cfg.chinaIpV4Set} --set-v6 ${cfg.chinaIpV6Set} --socks5 socks5://127.0.0.1:${builtins.toString mihomoCfg.socks5Port}";
        User = tproxyBypassUser;
        Group = tproxyBypassUser;
        StandardOutput = "journal";
        StandardError = "journal";
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
      };
    };
    timers."china-ip-updater" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.updateSchedule;
        RandomizedDelaySec = "15min";
        Persistent = false;
      };
    };
  };

  systemd.network.networks."${cfg.networkdUnitName}" = {
    name = "lo";
    routingPolicyRules = [
      {
        Family = "both";
        FirewallMark = builtins.toString cfg.tproxyMark;
        Priority = 10;
        Table = 100;
      }
    ];

    routes = [
      {
        Destination = "0.0.0.0/0";
        Type = "local";
        Table = 100;
      }
      {
        Destination = "::/0";
        Type = "local";
        Table = 100;
      }
    ];
  };
}
