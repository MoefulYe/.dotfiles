{
  lib,
  pkgs,
  config,
  rootPath,
  ...
}:
let
  cfg = config.networking.vpn.zju-connect;
in
{
  options.networking.vpn.zju-connect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ZJU Connect VPN.";
    };
    socks5Port = lib.mkOption {
      type = lib.types.int;
      default = 31080;
      description = "SOCKS5 proxy port for ZJU Connect VPN.";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      STU_ID = {
        sopsFile = "${rootPath}/secrets/zju.yaml";
      };
      STU_PASSWD = {
        sopsFile = "${rootPath}/secrets/zju.yaml";
      };
    };
    sops.templates."zju-connect.toml".content = ''
      username = "${config.sops.placeholder.STU_ID}"
      password = "${config.sops.placeholder.STU_PASSWD}"
      http_bind = ""
      socks_bind = ":${toString cfg.socks5Port}"
    '';
    systemd.services.zju-connect = {
      enable = cfg.enable;
      description = "ZJU Connect VPN Client";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.my-pkgs.zju-connect}/bin/zju-connect -config ${
          config.sops.templates."zju-connect.toml".path
        }";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
