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
        address = "192.168.231.3";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.231.1";
    interface = "enp131s0";
    metric = 100;
  };

  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 0;
      # interface = "enp131s0";
      bind-interfaces = true;
      dhcp-range = [ "192.168.231.128,192.168.231.254,255.255.255.0,12h" ];
      dhcp-option = [
        "option:router,192.168.231.3"
        "option:dns-server,192.168.231.3"
      ];
      listen-address = "192.168.231.3";
      log-dhcp = true;
    };
  };
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.firewall = {
    allowedUDPPorts = [
      67
    ];
  };
}
