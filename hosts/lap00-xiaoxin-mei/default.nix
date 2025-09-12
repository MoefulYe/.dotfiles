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
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
