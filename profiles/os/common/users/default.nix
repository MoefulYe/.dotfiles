{ lib, config, ... }:
with lib;
let
  cfg = config.osProfiles.common.users;
in
{

  osConfig = mkOption {
    type = types.attrs;
    default = { };
    description = "Attribute set for system-level user configuration (users.users.<name>).";
  };
  hmEntry = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "Path to the Home Manager entry file for this user.";
  };
  userInfo = mkOption {
    type = lib.types.attrs;
    default = { };
    description = "User information";
  };
  options.osProfiles.common.users = types.attrsOf (
    type.submodule {
      options = {
        inherit osConfig hmEntry userInfo;
      };
    }
  );
  config = {
    users.users = cfg |> (attrsets.mapAttrs (_: profile: profile.osConfig));
    home-manager.users =
      cfg
      |> (attrsets.filterAttrs (_: profile: profile.hmEntry != null))
      |> (attrsets.mapAttrs (
        username: profile:
        { lib, config, ... }:
        {
          home = {
            inherit (config.system) stateVersion;
            inherit username;
            homeDirectory = config.users.users."${username}".home;
          };
          imports = [
            profile.hmEntry
          ];
          options = {
            inherit userInfo;
          };
          config = {
            inherit (profile) userInfo;
          };
        }
      ));
  };
}
