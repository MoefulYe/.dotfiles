{
  inventory,
  ...
}:
let
  usbInterface = "enp5s0f3u1";
  bridgeInterface = "br0";
in
{
  imports = [
    # (inventory.topology.networks.void.nixosConfig.staticMemberNetworkdConfig {
    #   interface = bridgeInterface;
    # })
  ];
  systemd.network.netdevs."20-${bridgeInterface}" = {
    netdevConfig = {
      Name = bridgeInterface;
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-${usbInterface}" = {
    matchConfig.Name = usbInterface;
    networkConfig = {
      Bridge = bridgeInterface;
    };
  };
  systemd.network.networks."30-${bridgeInterface}" = {
    matchConfig.Name = bridgeInterface;
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = "no";
    };
    address = [ "192.168.231.4/24" ];
    gateway = [ "192.168.231.2" ];
    dns = [ "192.168.231.2" ];
  };
  systemd.network.networks.wlp2s0 = {
    enable = true;
    matchConfig.Name = "wlp2s0";
    linkConfig = {
      Unmanaged = true;
    };
  };
}
