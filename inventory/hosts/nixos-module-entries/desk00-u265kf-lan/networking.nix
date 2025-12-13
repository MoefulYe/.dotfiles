{
  paths,
  inventory,
  ...
}:
let
  inherit (paths) osProfiles;
  outbounds = [
    "wlp128s20f3"
    "enp131s0"
  ];
  defaultIface = "enp131s0";
in
{
  imports = [
    "${osProfiles}/features/networking/tproxy"
    "${osProfiles}/hardware/wireless.nix"
    inventory.topology.networks.void.nixosConfig.dnsmasqConfig
    (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
      interface = defaultIface;
      override = {
        networking.defaultGateway = {
          address = "192.168.231.1";
          interface = defaultIface;
          metric = 100;
        };
      };
    })
  ];
  osProfiles.features.tproxy = {
    nftables = {
      inherit outbounds;
    };
    smartdns = {
      enableAntiAD = true;
      extraSettings = inventory.topology.networks.void.smartdnsRecords;
    };
  };
  networking.interfaces.wlp128s20f3.useDHCP = true;
  systemd.network.networks."40-wlp128s20f3".dhcpV4Config.RouteMetric = 200;
}
