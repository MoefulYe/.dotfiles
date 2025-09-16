{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  proxyFwMark = 666;
  outbounds = [
    "enp131s0"
    "wlp128s20f3"
  ];
  tproxyPort = 7895;
in
{
  imports = [
    "${osProfiles}/features/networking/vpn/mihomo/presets/tproxy.nix"
    "${osProfiles}/features/networking/nftables/presets/tproxy.nix"
    "${osProfiles}/hardware/wireless.nix"
  ];
  config = {
    networking.interfaces.wlp128s20f3.useDHCP = true;
    networking.interfaces.enp131s0.useDHCP = true;
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
