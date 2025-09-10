{ lib, config, ... }: with lib; {
  options.osProfiles.users = types.attrsOf (
    type.submodule {
      options = {
        osConfig = mkOption {
          type = types.attrs;
          default = {};
          description = "Attribute set for system-level user configuration (users.users.<name>).";
        };
        hmEntry = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to the Home Manager entry file for this user.";
        };
        userInfo = mkOption {
          type = lib.types.attrs;
          default = {};
          description = "User information";
        };
      };
    }
  );
  config = {
    users.users = li
  };
}