{ config, pkgs, ... }: let 
  cfg = config.osProfiles.features.tproxy.nftables;
  generateChinaIPList = pkgs.callPackage ./generate-china-ip-list.nix { };
  mihomoTproxyPort = config.osProfiles.features.tproxy.mihomo.tproxyPort;
  table = ''

  '';
in
{
  systemd.services."my-mihomo".serviceConfig.StateDirectory = [ "nftables-china-ips" ];
  
}