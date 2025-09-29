{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  outbounds = [
    "wlp2s0"
  ];
  tproxyPort = 7895;
  dnsPort = 7853;
  zjuSocks5Port = 31085;
in
{
  imports = [
    "${osProfiles}/features/networking/mihomo/presets/tproxy.nix"
    "${osProfiles}/features/networking/nftables/presets/sys-fw.nix"
    "${osProfiles}/features/networking/nftables/presets/tproxy-v2-zju.nix"
    "${osProfiles}/features/networking/zju-connect/presets/default.nix"
    "${osProfiles}/hardware/wireless.nix"
  ];
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.nftables.presets.tproxy-v2-zju = {
    inherit tproxyPort dnsPort outbounds;
  };
  services.zju-connect.presets.default = {
    socks5Port = zjuSocks5Port;
  };
  services.mihomo.presets.tproxy = {
    inherit tproxyPort dnsPort;
    zjuConnect = {
      enable = true;
      socks5Port = zjuSocks5Port;
    };
  };
}
