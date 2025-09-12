{ config, paths, ... }:
let
  inherit (paths) osProfiles myOsModules;
  proxyFwMark = 666;
  outbounds = [
    "enp131s0"
    "wlp128s20f3"
  ];
  tproxyPort = 7895;
in
{
  imports = [
    "${osProfiles}/features/networking/vpn/mihomo/presets/tproxy"
    "${osProfiles}/features/networking/nftables/presets/tproxy"
  ];
  config = {
    sops.secrets = {
      STU_ID = {
        mode = "0400";
        sopsFile = "${paths.secrets}/zju.yaml";
      };
      STD_PASSWD = {
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
    networking.nftables.presets.tproxy = {
      inherit tproxyPort proxyFwMark outbounds;
    };
    services.mihomo.presets.tproxy = {
      inherit tproxyPort;
      routingMark = proxyFwMark;
      zjuConnect = {
        enable = false;
        socks5Port = 0;
      };
    };
  };
}
