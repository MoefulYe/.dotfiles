{
  inputs,
  lib,
  config,
  paths,
  pkgs,
  ...
}:
with lib;
{
  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit paths inputs;
        inherit (config) hostInfo;
      };
      backupFileExtension = "bak";
    };
  };
}