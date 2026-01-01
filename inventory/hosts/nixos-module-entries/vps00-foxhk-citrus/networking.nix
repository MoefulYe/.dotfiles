{
    networking.interfaces."ens17" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "45.192.104.103";
            prefixLength = 24;
          }
        ];
    };
    networking.defaultGateway = {
      address = "45.192.104.1"; 
      interface = "ens17";
    };
    networking.nameservers = [ "8.8.8.8" ];
}