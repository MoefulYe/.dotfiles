{ paths, ... }:
let
  inherit (paths) osProfiles osRoles;
in
{
  imports = [
    "${osRoles}/cat"
    "${osRoles}/daily"
    "${osProfiles}/hardware/nvidia-daily"
    "${osProfiles}/features/streaming/sunshine.nix"
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
    ./users
  ];
}
