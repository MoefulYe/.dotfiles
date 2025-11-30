{ inputs, pkgs, ... }:
{
  imports =
    if pkgs.stdenv.isLinux then
      [
        inputs.nix-index-database.nixosModules.nix-index
      ]
    else
      [
        inputs.nix-index-database.darwinModules.nix-index
      ];
}
