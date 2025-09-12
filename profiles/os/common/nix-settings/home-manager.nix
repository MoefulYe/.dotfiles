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
    backupFileExtension = "bakup-" + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {
          env.when = inputs.self.sourceInfo.lastModified;
        } "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
};
}
