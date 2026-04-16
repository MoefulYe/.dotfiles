{
  paths,
  inventory,
  ...
}@input:
let
  inherit (paths) osProfiles;
  defaultIface = "enp130s0";
  macvlanIface = "mv-enp131s0";
  void = import "${paths.infra}/network/void.nix" input;
in
{
  imports = [
    "${osProfiles}/hardware/wireless.nix"
    (void.nixosConfig.default {
      interface = macvlanIface;
      address = "192.168.231.2";
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
