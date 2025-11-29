{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  outbounds = [
    "enp5s0f3u1"
  ];
in
{
  networking.interfaces.wlp2s0.enable = false;
  networking.interfaces.enp5s0f3u1 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.3";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "192.168.1.2";
  networking.nameservers = [ "192.168.1.2" ];
}
