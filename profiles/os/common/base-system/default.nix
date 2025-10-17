{ lib, ... }:
{
  imports = [
    ./i18n.nix
    ./sysctl.nix
    ./bootloader.nix
  ];
}
