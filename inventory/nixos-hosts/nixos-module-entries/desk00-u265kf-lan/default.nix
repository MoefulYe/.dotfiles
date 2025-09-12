{ paths, ... }:
let
  inherit (paths) osProfiles osRoles;
in
{
  imports = [
    "${osRoles}/cat"
    "${osRoles}/daily"
    "${osProfiles}/hardware/nvidia-daily.nix"
    "${osProfiles}/features/streaming/sunshine.nix"
    "${osProfiles}/features/gaming/steam.nix"
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
    ./users
  ];
  # FIXME
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "libxml2-2.13.8"
  ];
}
