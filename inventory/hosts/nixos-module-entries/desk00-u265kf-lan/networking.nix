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
  networking.interfaces.enp131s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp131s0";
    metric = 100;
  };

  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;
}
