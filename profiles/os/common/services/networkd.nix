{ lib, ... }:
{

  services.systemd-networkd.enable = lib.mkDefault true;
}
