{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--advertise-routes=192.168.231.0/24"
    "--accept-dns=false"
  ];
}
