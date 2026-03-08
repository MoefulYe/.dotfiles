{ ... }:
let
  iface = "ens5";
in
{
  systemd.network.networks."40-${iface}" = {
    matchConfig.Name = iface;
    networkConfig = {
      DHCP = "ipv4"; # or "yes" for ipv4+ipv6
    };
  };
}
