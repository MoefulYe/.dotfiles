{ lib, ... }:
{
  networking = {
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    defaultGateway = {
      address = "198.252.98.190";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "";
      interface = "ens3";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      ens3 = {
        ipv4.addresses = [
          { address = "198.252.98.154"; prefixLength = 26; }
        ];
        ipv6.addresses = [
          { address = "fe80::245:4fff:fee0:e968"; prefixLength = 64; }
        ];
        ipv4.routes = [ { address = "198.252.98.190"; prefixLength = 32; } ];
        ipv6.routes = [ { address = ""; prefixLength = 128; } ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="00:45:4f:e0:e9:68", NAME="ens3"
  '';
}
