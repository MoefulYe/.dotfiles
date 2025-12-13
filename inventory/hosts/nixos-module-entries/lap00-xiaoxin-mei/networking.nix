{
  inventory,
  ...
}:
let
  interface = "enp5s0f3u1";
in
{
  imports = [
    (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
      inherit interface;
    })
  ];
  systemd.network.networks.wlp2s0 = {
    enable = true;
    matchConfig.Name = "wlp2s0";
    linkConfig = {
      Unmanaged = true;
    };
  };
}
