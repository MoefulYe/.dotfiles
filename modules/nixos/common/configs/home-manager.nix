{
  inputs,
  lib,
  config,
  rootPath,
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
        inherit inputs rootPath;
        inherit (config) systemProfiles;
      };
      # MOVE
      # backupFileExtension =
      #   "bakup-"
      #   + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {
      #     env.when = inputs.self.sourceInfo.lastModified;
      #   } "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
      backupFileExtension = "bak";
      users = config.systemProfiles.basic.users.hmModules;
    };
  };
}
