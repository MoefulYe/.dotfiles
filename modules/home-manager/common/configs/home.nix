{ config, systemProfiles, ... }:
{
  home = {
    inherit (config.userProfiles) username homeDirectory;
    inherit (systemProfiles.basic.host) stateVersion;
  };
  programs.home-manager.enable = true;
}
