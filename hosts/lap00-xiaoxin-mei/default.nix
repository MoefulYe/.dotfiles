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
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
