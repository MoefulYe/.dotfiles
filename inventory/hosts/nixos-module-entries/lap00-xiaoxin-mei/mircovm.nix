{ inputs, ... }:
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
  microvm.vms."vm-test".config = {

    microvm = {

      # "qemu" has 9p built-in!
      hypervisor = "cloud-hypervisor";
      # hotplugMem = TODO;
      # hotpluggedMem = TODO;
      mem = 2048;
      # storeDiskErofsFlags = TODO;
      # storeDiskType = TODO;
      # storeOnDisk = TODO;
      vcpu = 2;
      # virtiofsd = { TODO };
      # volumes = [ TODO ]
      # 数据卷配置
      # writableStoreOverlay = TODO;
    };
  };
}
