{
  bee = {
    address = "192.168.231.67/24";
    gateway = "192.168.231.2";
    dns = "192.168.231.2";
    tapId = "vm-black";
    mac = "52:54:00:aa:bb:03";
    volumes = [
      {
        mountPoint = "/var";
        image = "/dev/vg_pool/vm3";
        size = 1024 * 64;
        fsType = "ext4";
      }
    ];
  };
  vcpu = 4;
  mem = 4096;
}
