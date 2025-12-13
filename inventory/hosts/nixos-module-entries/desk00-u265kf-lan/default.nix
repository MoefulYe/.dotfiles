{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/hardware/nvidia-daily.nix"
    "${osProfiles}/features/streaming/sunshine.nix"
    "${osProfiles}/features/gaming/steam.nix"
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
    ./libvirtd.nix
    ./users.nix
    ./remote-builder.nix
  ];
}
