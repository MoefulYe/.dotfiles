{
  config,
  lib,
  paths,
  pkgs,
  ...
}:
let
  cfg = config.osProfiles.features.tproxy.extraProxies.zju-connect;
  user = config.osProfiles.features.tproxy.tproxyBypassUser.name;
in
{
  config = lib.mkIf cfg.enable {
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
    systemd.services.zju-connect = {
      enable = true;
      description = "ZJU Connect VPN Client";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.my-pkgs.zju-connect}/bin/zju-connect -config ${config.sops.templates."zju-connect.toml".path}";
        Restart = "on-failure";
        RestartSec = "5s";
        User = user;
        Group = user;
      };
    };
  };
}
