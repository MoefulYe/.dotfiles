{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.systemProfiles.common = {
    host = {
      name = mkOption {
        type = types.str;
      };
      stateVersion = mkOption {
        type = types.str;
        description = "dont change this unless you know what you are doing";
      };
      description = mkOption {
        type = types.nullOr types.str;
        description = "basic description for this host";
      };
    };
    users = {
      users = mkOption {
        type = types.attrs;
        default = { };
      };
      # 传递给 home-manager 的用户配置
      hmModules =
        let
          hmModule = types.anything;
        in
        mkOption {
          type = types.attrsOf hmModule;
          default = { };
        };
    };
    i18n = {
      timezone = mkOption {
        type = types.str;
        default = "Asia/Shanghai";
      };
      locale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
      };
    };
  };
}
