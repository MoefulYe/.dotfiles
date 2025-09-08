{
  lib,
  config,
  pkgs,
  secretsPath,
  ...
}:
let
  cfg = config.networking.vpn.mihomo;
  preset = import ../../../../modules/nixos/common/networking/vpn/mihomo/presets/preset0.nix;
  secrets = config.sops.placeholder;
  zju-connect-cfg = config.networking.vpn.zju-connect;
  #  providers map yaml key
  providers = [
    "ikuuu"
    "leiting"
    "mojie"
    # "linuxdo"
    "pokemon"
  ];
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
      enable = false;
      socks5Port = 31080;
    };
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = config.sops.templates."mihomo.yaml".path;
      webui = pkgs.metacubexd;
    };
    sops.secrets = {
      MIHOMO_WEB_UI_PASSWD = {
        sopsFile = "${secretsPath}/per-host/desk00-u265kf-lan/default.yaml";
      };
    }
    // (
      providers
      |> builtins.map (name: {
        inherit name;
        value = {
          sopsFile = "${secretsPath}/mihomo.yaml";
        };
      })
      |> builtins.listToAttrs
    );
    sops.templates."mihomo.yaml".content = preset {
      inherit lib;
      tproxy-port = cfg.tproxyPort;
      routing-mark = cfg.mihomoMark;
      external-controller-secret = secrets.MIHOMO_WEB_UI_PASSWD;
      proxy-providers =
        providers
        |> builtins.map (name: {
          inherit name;
          value = secrets.${name};
        })
        |> builtins.listToAttrs;
      inherit zju-connect-cfg;
    };
  };
}
