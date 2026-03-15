{ ... }:
let
  iface = "ens5";
in
{
  systemd.network.networks."40-${iface}" = {
    matchConfig.Name = iface;
    networkConfig = {
      DHCP = "ipv4";
    };
  };

  infra.dnsctl = {
    ipv4 = "43.130.59.57";
    domain = "pippaye.top";
  };
}
