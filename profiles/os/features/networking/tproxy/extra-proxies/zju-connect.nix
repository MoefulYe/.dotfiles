{
  config,
  lib,
  paths,
  ...
}:
let
  cfg = config.services.zju-connect.presets.default;
  inherit (paths) osModules;
in
{
  imports = [
    "${osModules}/services/zju-connect.nix"
  ];
  options.services.zju-connect.presets.default = {
    socks5Port = lib.mkOption {
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
      username = "${config.sops.placeholder.STU_ID}"
      password = "${config.sops.placeholder.STU_PASSWD}"
      socks_bind = ":${builtins.toString cfg.socks5Port}"
      http_bind = ""
    '';
    services.zju-connect = {
      configFile = config.sops.templates."zju-connect.toml".path;
    };
  };
}
