{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
with inputs;
{
  imports = [
    nix-index-database.nixosModules.nix-index
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./configuration.nix
    ./disko.nix
    ./modules
  ];
}
