{ config, pkgs, ... }: let 
  cfg = config.osProfiles.features.tproxy.nftables;
  mihomoCfg = config.osProfiles.features.tproxy.mihomo;
  tproxyBypassUser = config.osProfiles.features.tproxy.tproxyBypassUser.name;
  generateChinaIPList = pkgs.callPackage ./generate-china-ip-list.nix { 
    inherit cfg;
  };
  table = pkgs.callPackage ./table.nix { 
    inherit config mihomoCfg tproxyBypassUser;
  };
  mihomoNftablesCtl = pkgs.callPackage ./mihomo-nftables-ctl.nix { 
    inherit generateChinaIPList table cfg;
  };
in
{
  systemd.services."my-mihomo".serviceConfig = {
    StateDirectory = [ cfg.chinaIpListDirname ];
    PermissionsStartOnly = true;
    ExecStartPre = [ "+${mihomoNftablesCtl} up" ];
    ExecStopPost = [ "+${mihomoNftablesCtl} down" ];
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