{ config, paths, ... }:
let
  inherit (paths) osProfiles osModules;
  zjuConnectSock5Port = 31080;
  proxyFwMark = 666;
  outbounds = [
    "wlp2s0"
  ];
  tproxyPort = 7895;
in
{
  imports = [
    "${osProfiles}/features/networking/vpn/mihomo/presets/tproxy.nix"
    "${osProfiles}/features/networking/nftables/presets/tproxy-zju.nix"
    "${osModules}/services/zju-connect.nix"
  ];
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
      http_bind = ""
      socks_bind = ":${toString config.services.zju-connect.socks5Port}"
    '';
    services.zju-connect = {
      socks5Port = zjuConnectSock5Port;
      configPath = config.sops.templates."zju-connect.toml".path;
    };
    networking.nftables.presets.tproxy = {
      inherit tproxyPort proxyFwMark outbounds;
    };
    services.mihomo.presets.tproxy = {
      inherit tproxyPort;
      routingMark = proxyFwMark;
      zjuConnect = {
        enable = true;
        socks5Port = zjuConnectSock5Port;
      };
    };
  };
}
