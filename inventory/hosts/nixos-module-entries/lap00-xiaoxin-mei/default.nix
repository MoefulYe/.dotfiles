{ paths, ... }: let
  inherit (paths) infra;
in {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix
    ./power-management.nix
    ./minecraft.nix
    ./minecraft-bakup.nix
    "${infra}/remote-builder.nix"
  ];
}
