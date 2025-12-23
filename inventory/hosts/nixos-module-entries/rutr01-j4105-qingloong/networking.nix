{
  paths,
  inventory,
  ...
}:
let
  inherit (paths) osProfiles;
  outbounds = [
    "enp1s0"
  ];
  defaultIface = "enp1s0";
in
{
  imports = [
    "${osProfiles}/features/networking/tproxy"
    inventory.topology.networks.void.nixosConfig.dnsmasqConfig
    (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
      interface = defaultIface;
      override = {
        networking.defaultGateway = {
          address = "192.168.231.1";
          interface = defaultIface;
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
      staticRecords = inventory.topology.networks.void.smartdnsRecords;
    };
  };
}
