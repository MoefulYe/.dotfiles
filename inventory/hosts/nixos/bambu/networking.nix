{ paths, ... }@input:
let
  wanIface = "wan";
  lanIface = "lan";
  macvlanIface = "mvlan";
  wanMac = "e4:3a:6e:83:65:38";
  lanMac = "e4:3a:6e:83:65:39";
  void = import "${paths.infra}/network/void.nix" input;
in
{
  imports = [
    (void.nixosConfig.gateway {
      lanInterface = macvlanIface;
      lanAddress = "192.168.231.1";
    })
    "${paths.osProfiles}/features/networking/tproxy"
  ];

  osProfiles.features.tproxy = {
    nftables = {
      outbounds = [ wanIface ];
    };
    smartdns = {
      enableAntiAD = true;
    };
  };
  # services.resolved.enable = true;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.links."10-${wanIface}" = {
    matchConfig.MACAddress = wanMac;
    linkConfig.Name = wanIface;
  };

  systemd.network.links."10-${lanIface}" = {
    matchConfig.MACAddress = lanMac;
    linkConfig.Name = lanIface;
  };

  systemd.network.networks."40-${wanIface}" = {
    matchConfig.Name = wanIface;
    networkConfig = {
      DHCP = "ipv4"; # or "yes" for ipv4+ipv6
    };
  };

  systemd.network.netdevs."20-${macvlanIface}" = {
    netdevConfig = {
      Name = macvlanIface;
      Kind = "macvlan";
    };
    macvlanConfig = {
      Mode = "bridge";
    };
  };

  systemd.network.networks."30-${lanIface}" = {
    matchConfig.Name = lanIface;
    networkConfig = {
      MACVLAN = macvlanIface;
    };
  };
}
