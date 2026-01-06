{
  paths,
  inventory,
  lib,
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
      networkdConfigname = "40-${defaultIface}";
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
  systemd.network.networks."40-${defaultIface}" = {
    networkConfig = {
      Gateway = lib.mkForce [
        "192.168.231.1"
      ];
    };
  };
}
