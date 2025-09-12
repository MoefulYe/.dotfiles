{
  desk00-u265kf-lan = {
    nixosModuleEntry = ./nixos-module-entries/desk00-u265kf-lan;
    hostInfo = {
      system = "x86_64-linux";
      tags = [ "daily" ];
      description = "daily used desktop";
    };
  };
  lap00-xiaoxin-mei = {
    nixosModuleEntry = ../../hosts/lap00-xiaoxin-mei;
    hostInfo = {
      system = "x86_64-linux";
      tags = [ "daily" ];
      description = ./nixos-module-entries/lap00-xiaoxin-mei;
    };
  };
}
