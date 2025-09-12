{
  inputs,
  lib,
  config,
  paths,
  pkgs,
  ...
}:
{
  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit paths inputs;
        inherit (config.osProfiles.common) hostInfo;
      };
      backupFileExtension = "bak";
    };
  };
}
