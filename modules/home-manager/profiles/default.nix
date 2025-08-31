{ config, lib, ... }:
{
  options.userProfiles = {
    username = lib.mkOption {
      type = lib.types.str;
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.userProfiles.username}";
    };
    email = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    enableZjuLabSsh = lib.mkEnableOption "enable ssh configuration for zju lab serv connection";
  };
}
