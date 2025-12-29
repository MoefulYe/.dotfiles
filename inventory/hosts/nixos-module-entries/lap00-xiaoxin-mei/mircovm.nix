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
    # "vm01-lap00-red" = {
    #   flake = outputs;
    #   restartIfChanged = true;
    # };
    # "vm02-lap00-white" = {
    #   flake = outputs;
    #   restartIfChanged = true;
    # };
    # "vm03-lap00-black" = {
    #   flake = outputs;
    #   restartIfChanged = true;
    # };
  };
}
