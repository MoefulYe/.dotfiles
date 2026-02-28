{
  paths,
  inventory,
  ...
}:
let
  inherit (paths) osProfiles;
  defaultIface = "enp131s0";
  macvlanIface = "mv-enp131s0";
in
{
  imports = [
    "${osProfiles}/hardware/wireless.nix"
    (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
      interface = macvlanIface;
    })
  ];
  networking.interfaces.wlp128s20f3.useDHCP = true;
  networking.interfaces.enp131s0.useDHCP = false;
  networking.interfaces.${macvlanIface}.useDHCP = false;
  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;

  systemd.network.netdevs."20-${macvlanIface}" = {
    netdevConfig = {
      Name = macvlanIface;
      Kind = "macvlan";
    };
    macvlanConfig = {
      Mode = "bridge";
    };
  };

  systemd.network.networks."10-${defaultIface}" = {
    matchConfig.Name = defaultIface;
    networkConfig = {
      MACVLAN = macvlanIface;
    };
  };
}
