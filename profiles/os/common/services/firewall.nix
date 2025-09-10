{ lib, ... }:
{
  networking.nftables.enable = lib.mkDefault true;
  networking.firewall.enable = lib.mkDefault true;
}
