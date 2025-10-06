{ config, pkgs, ... }: let 
  cfg = config.osProfiles.features.tproxy.nftables;
  mihomoCfg = config.osProfiles.features.tproxy.mihomo;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;
  generateChinaIPList = pkgs.callPackage ./generate-china-ip-list.nix { 
    inherit cfg;
  };
  table = pkgs.callPackage ./table.nix { 
    inherit config mihomoCfg tproxyBypassUser cfg;
  };
  mihomoNftablesCtl = pkgs.callPackage ./mihomo-nftables-ctl.nix { 
    inherit generateChinaIPList table cfg;
  };
  chinaIpUpdater = pkgs.callPackage ./china-ip-updater.nix {
    inherit generateChinaIPList cfg;
  };
in
{
  networking.nftables.enable = true;
  systemd.services."my-mihomo".serviceConfig = {
    StateDirectory = [ cfg.chinaIpListDirname ];
    PermissionsStartOnly = true;
    ExecStartPre = [ "+${mihomoNftablesCtl} up" ];
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
}