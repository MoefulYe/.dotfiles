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
  microvm.vms."vm-test".config = {
    networking.hostName = "my-microvm";
    users.users.root.password = "";
    services.openssh.enable = true;
    microvm = {
      volumes = [
        {
          mountPoint = "/var";
          image = "var.img";
          size = 256;
        }
      ];
      shares = [
        {
          # use proto = "virtiofs" for MicroVMs that are started by systemd
          proto = "9p";
          tag = "ro-store";
          # a host's /nix/store will be picked up so that no
          # squashfs/erofs will be built for it.
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
        # 根目录配置
      ];
      interfaces = [
        {
          type = "tap";
          id = "vm-test";
          mac = "02:00:00:00:00:01";
        }
      ];

      # "qemu" has 9p built-in!
      hypervisor = "qemu";
      socket = "control.socket";
    };
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
}
