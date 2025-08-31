{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./profiles
    ./common
    inputs.stylix.homeModules.stylix
  ];
}
