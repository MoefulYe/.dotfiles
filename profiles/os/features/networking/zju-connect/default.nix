{
  config,
  lib,
  paths,
  ...
}:
let
  cfg = config.services.zju-connect.presets.default;
in
{
  options.services.zju-connect.presets.default = {
    sock5Port = lib.mkOption {
      type = lib.types.int;
      default = 31085;
    };
  };

  config = {
    sops.secrets = {
      STU_ID = {
        mode = "0400";
        sopsFile = "${paths.secrets}/zju.yaml";
      };
      STU_PASSWD = {
        mode = "0400";
        sopsFile = "${paths.secrets}/zju.yaml";
      };
    };
    sops.templates."zju-connect.toml".content = ''
      username = ${config.sops.placeholder.STU_ID}
      password = ${config.sops.placeholder.STU_PASSWD}
      socks-bind = :${cfg.sock5Port}
      http-bind = ""
    '';
    services.zju-connect = {
      configFile = config.sops.templates."zju-connect.toml".path;
    };
  };
}
