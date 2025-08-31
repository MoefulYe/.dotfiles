{
  inputs,
  lib,
  config,
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
        inherit inputs;
        inherit (config) systemProfiles;
      };
      backupFileExtension =
        "bakup-"
        + pkgs.lib.readFile "${pkgs.runCommand "timestamp" {
          env.when = inputs.self.sourceInfo.lastModified;
        } "echo -n `date '+%Y%m%d%H%M%S'` > $out"}";
      users = config.systemProfiles.basic.users.hmModules;
    };
  };
}
