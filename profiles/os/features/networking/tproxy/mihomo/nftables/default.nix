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
  table = pkgs.callPackage ./table.nix {
    inherit
      config
      mihomoCfg
      tproxyBypassUser
      cfg
      ;
  };
in
{
  networking.nftables.enable = true;
  systemd =
    let
      chinaIpListPath = "/var/lib/${cfg.chinaIpListDirname}/${cfg.chinaIPListBasename}";
      downloadChinaIPList = pkgs.callPackage ./download-china-ip-list.nix {
        inherit (pkgs.my-pkgs) downloader;
      };
      mihomoNftablesCtl = pkgs.callPackage ./mihomo-nftables-ctl.nix { };
      updateChinaIpList = pkgs.writeShellScript "update-china-ip-list" ''
        ${lib.getExe downloadChinaIPList} --dest ${chinaIpListPath} --socks5 socks5://127.0.0.1:${toString mihomoCfg.socks5Port}
        (
          echo "table inet mihomo-tproxy {"
          cat "${chinaIpListPath}"
          echo "}"
        ) | ${pkgs.nftables}/bin/nft -f -
        if [ $? -ne 0 ]; then
          echo "Failed to update nftables with new China IP list"
          exit 1
        else
          echo "Successfully updated China IP list and nftables"
        fi
      '';
      inherit (pkgs.my-pkgs) ensure-exist;
    in
    {
      services."my-mihomo".serviceConfig = {
        StateDirectory = [ cfg.chinaIpListDirname ];
        PermissionsStartOnly = true;
        ExecStartPre = [
          "+${lib.getExe ensure-exist} ${chinaIpListPath} ${lib.getExe downloadChinaIPList} --dest ${chinaIpListPath}"
          "+${lib.getExe mihomoNftablesCtl} up --table-file ${table}"
        ];
        ExecStopPost = [ "+${lib.getExe mihomoNftablesCtl} down" ];
      };
      services."china-ip-updater" = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${updateChinaIpList}";
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
      network.networks."${cfg.networkdUnitName}" = {
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
    };

}
