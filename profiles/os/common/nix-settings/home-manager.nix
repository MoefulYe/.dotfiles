{
  inputs,
  config,
  paths,
  inventory,
  pkgs,
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
    backupFileExtension = "bakup"; # 禁用备份文件
  };
}
