{
  paths,
  inventory,
  ...
}:
let
  inherit (paths) osProfiles;
  defaultIface = "enp131s0";
in
{
  imports = [
    "${osProfiles}/hardware/wireless.nix"
    inventory.topology.networks.void.nixosConfig.dnsmasqConfig
    (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
      interface = defaultIface;
    })
  ];
  networking.interfaces.wlp128s20f3.useDHCP = true;
  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;
}
