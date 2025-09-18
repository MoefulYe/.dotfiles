{ paths, pkgs, ... }:
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
  systemd.network = {
    netdevs = {
      "20-vbr0".netdevConfig = {
        Name = "vbr0";
        Kind = "bridge";
      };
      "30-veth" = {
        netdevConfig = {
          Kind = "veth";
          Name = "veth0";
        };
        peerConfig = {
          Name = "veth1";
        };
      };
    };
  };
}
