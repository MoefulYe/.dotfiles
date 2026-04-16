{ ... }:
let
  wanIface = "wan";
  lanIface = "lan";
  wanMac = "e4:3a:6e:83:65:38";
  lanMac = "e4:3a:6e:83:65:39";
in
{
  services.resolved.enable = true;
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
}
