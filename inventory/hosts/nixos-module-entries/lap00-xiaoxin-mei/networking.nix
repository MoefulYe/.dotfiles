{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  outbounds = [
    "enp5s0f3u1"
  ];
in
{
  networking.interfaces.enp5s0f3u1 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.231.4";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.231.3";
    interface = "enp5s0f3u1";
  };
  networking.nameservers = [ "192.168.231.3" ];
  systemd.network.networks.wlp2s0 = {
    enable = true;
    matchConfig.Name = "wlp2s0";
    linkConfig = {
      Unmanaged = true;
    };
  };
}
