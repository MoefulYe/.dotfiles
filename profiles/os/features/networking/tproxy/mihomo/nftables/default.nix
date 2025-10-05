{ config, pkgs, ... }: let 
  generateChinaIPList = pkgs.callPackage ./generate-china-ip-list.nix { };
  table = ''

  '';
in
{
  systemd.services."my-mihomo".serviceConfig.StateDirectory = [ "nftables-china-ips" ];
  
}