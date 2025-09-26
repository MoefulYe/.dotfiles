{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  proxyFwMark = 666;
  outbounds = [
    "wlp2s0"
  ];
  tproxyPort = 7895;
  dnsPort = 7853;
in
{
  imports = [
    "${osProfiles}/features/networking/mihomo/presets/tproxy.nix"
    "${osProfiles}/features/networking/nftables/presets/tproxy-v2.nix"
    "${osProfiles}/features/networking/nftables/presets/sys-fw.nix"
    "${osProfiles}/hardware/wireless.nix"
  ];
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.nftables.presets.tproxy-v2 = {
    inherit tproxyPort dnsPort outbounds;
  };
  services.mihomo.presets.tproxy = {
    inherit tproxyPort dnsPort;
    zjuConnect.enable = false;
  };
}
