{
  bee = {
    address = "192.168.231.66/24";
    gateway = "192.168.231.2";
    dns = "192.168.231.2";
    tapId = "vm-white";
    mac = "52:54:00:aa:bb:02";
    volumes = [
      {
        mountPoint = "/var";
        image = "/dev/vg_pool/vm2";
        size = 1024 * 64;
        fsType = "ext4";
      }
    ];
  };
  vcpu = 4;
  mem = 4096;
}
