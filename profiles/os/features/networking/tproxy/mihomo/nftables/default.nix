{ config, pkgs, ... }:
let
  cfg = config.osProfiles.features.tproxy.nftables;
  mihomoCfg = config.osProfiles.features.tproxy.mihomo;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;
  downloadChinaIPList = pkgs.callPackage ./download-china-ip-list.nix { };
  table = pkgs.callPackage ./table.nix {
    inherit
      config
      mihomoCfg
      tproxyBypassUser
      cfg
      ;
  };
  mihomoNftablesCtl = pkgs.callPackage ./mihomo-nftables-ctl.nix {
    inherit downloadChinaIPList table cfg;
  };
  chinaIpUpdater = pkgs.callPackage ./china-ip-updater.nix {
    inherit downloadChinaIPList cfg mihomoCfg;
  };
in
{
  networking.nftables.enable = true;
  systemd.services."my-mihomo".serviceConfig = {
    StateDirectory = [ cfg.chinaIpListDirname ];
    PermissionsStartOnly = true;
    ExecStartPre = [ ''+${mihomoNftablesCtl} up \
      --table-file ${table} \
      --china-dir "/var/lib/${cfg.chinaIpListDirname}" \
      --china-name "${cfg.chinaIPListBasename}" \
      --set-v4 "${cfg.chinaIpV4Set}" \
      --set-v6 "${cfg.chinaIpV6Set}"
    '' ];
    ExecStopPost = [ "+${mihomoNftablesCtl} down" ];
  };
  systemd.services."china-ip-updater" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${chinaIpUpdater}";
      User = tproxyBypassUser;
      Group = tproxyBypassUser;
      StandardOutput = "journal";
      StandardError = "journal";
      AmbientCapabilities = "CAP_NET_ADMIN";
      CapabilityBoundingSet = "CAP_NET_ADMIN";
    };
  };

  systemd.timers."china-ip-updater" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = cfg.updateSchedule;
      RandomizedDelaySec = "15min";
      Persistent = false;
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
