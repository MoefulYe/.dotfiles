{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/vps"
    ./finetune.nix
    ./networking.nix
    ./users.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
