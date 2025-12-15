{ paths, ... }:
let
  inherit (paths) osProfiles infra;
in
{
  imports = [
    "${osProfiles}/hardware/nvidia-daily.nix"
    "${osProfiles}/features/streaming/sunshine.nix"
    "${osProfiles}/features/gaming/steam.nix"
    "${infra}/remote-builder/server.nix"
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
    ./libvirtd.nix
    ./users.nix
    ./binfmt-misc.nix
  ];
}
