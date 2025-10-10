{ paths, ... }:
let
  inherit (paths) osProfiles;
  outbounds = [
    "wlp128s20f3"
    "enp131s0"
  ];
in
{
  imports = [
    "${osProfiles}/features/networking/tproxy"
    "${osProfiles}/hardware/wireless.nix"
  ];
  osProfiles.features.tproxy = {
    nftables = {
      inherit outbounds;
    };
    smartdns = {
      enableAntiAD = true;
    };
  };
  networking.interfaces.wlp128s20f3.useDHCP = true;
  networking.interfaces.enp131s0.useDHCP = true;

  systemd.network.networks."40-enp131s0".dhcpV4Config.RouteMetric = 100;
  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;
}
