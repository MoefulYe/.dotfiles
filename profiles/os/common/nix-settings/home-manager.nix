{
  inputs,
  config,
  paths,
  inventory,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit paths inputs inventory;
      inherit (config.osProfiles.common) hostInfo;
    };
    backupFileExtension = builtins.getEnv "BAKUP_EXT";
  };
}
