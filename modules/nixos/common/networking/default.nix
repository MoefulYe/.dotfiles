{ config, ... }:
{
  imports = [
    ./vpn
  ];
  networking.hostName = config.systemProfiles.basic.host.name;
}
