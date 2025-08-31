{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.systemProfiles.basic = {
    host = {
      name = mkOption {
        type = types.str;
      };
      stateVersion = mkOption {
        type = types.str;
        description = "dont change this unless you know what you are doing";
      };
      type = mkOption {
        type = types.enum [
          "laptop"
          "desktop"
          "server"
          "unknown"
        ];
        default = "unknown";
        description = "Type of the host machine.";
      };
      description = mkOption {
        type = types.nullOr types.str;
        description = "basic description for this host";
      };
    };
    me = {
      username = mkOption {
        type = types.str;
        default = "ashenye";
      };
      email = mkOption {
        type = types.str;
        default = "luren145@gmail.com";
      };
    };
    users = {
      # TODO 配置除了 me 之外的用户
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
