{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.zju-connect;
in
{
  # TODO improve scureity
  options.services.zju-connect = {
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
    configPath = lib.mkOption {
      type = lib.types.path;
      description = "config file for ZJU Connect";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.zju-connect = {
      enable = cfg.enable;
      description = "ZJU Connect VPN Client";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.my-pkgs.zju-connect}/bin/zju-connect -config ${cfg.configPath}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}

