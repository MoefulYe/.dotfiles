{ inputs, outputs, ... }:
{
  imports = [
    inputs.microvm.nixosModules.host
  ];
  systemd.network.networks."50-mircovm-tap-bridge" = {
    matchConfig.Name = "vm-*";
    networkConfig = {
      Bridge = "br0";
    };
  };
  users.users."microvm".extraGroups = [ "disk" ];
  microvm.vms = {
    "vm00-lap00-azure" = {
      flake = outputs;
      restartIfChanged = true;
    };
  };
}
