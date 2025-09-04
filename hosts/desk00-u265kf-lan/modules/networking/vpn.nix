{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.networking.vpn.mihomo;
  preset = import ../../../../modules/nixos/common/networking/vpn/mihomo/presets/preset0.nix;
  secrets = config.sops.placeholder;
  zju-connect-cfg = config.networking.vpn.zju-connect;
in
{
  options.networking.vpn.mihomo = {
    tproxyPort = lib.mkOption {
      type = lib.types.int;
      default = 7895;
    };
    mihomoMark = lib.mkOption {
      type = lib.types.int;
      default = 666;
    };
  };
  config = {
    networking.vpn.zju-connect = {
      enable = true;
      socks5Port = 31080;
    };
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = config.sops.templates."mihomo.yaml".path;
      webui = pkgs.metacubexd;
    };
    sops.secrets = {
      MIHOMO_IKUUU = {
        sopsFile = ../../../../secrets/mihomo.yaml;
      };
      MIHOMO_LEITING = {
        sopsFile = ../../../../secrets/mihomo.yaml;
      };
      MIHOMO_MOJIE = {
        sopsFile = ../../../../secrets/mihomo.yaml;
      };
      MIHOMO_LINUXDO = {
        sopsFile = ../../../../secrets/mihomo.yaml;
      };
      MIHOMO_POKEMON = {
        sopsFile = ../../../../secrets/mihomo.yaml;
      };
      MIHOMO_WEB_UI_PASSWD = {
        sopsFile = ../../../../secrets/per-host/desk00-u265kf-lan/default.yaml;
      };
    };
    sops.templates."mihomo.yaml".content = preset {
      inherit lib;
      tproxy-port = cfg.tproxyPort;
      routing-mark = cfg.mihomoMark;
      external-controller-secret = secrets.MIHOMO_WEB_UI_PASSWD;
      proxy-providers = {
        ikuuu = secrets.MIHOMO_IKUUU;
        leiting = secrets.MIHOMO_LEITING;
        mojie = secrets.MIHOMO_MOJIE;
        pokemon = secrets.MIHOMO_POKEMON;
        # linuxdo = secrets.MIHOMO_LINUXDO;
      };
      inherit zju-connect-cfg;
    };
  };
}
