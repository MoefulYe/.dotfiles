{
  bee = {
    address = "192.168.231.65/24";
    gateway = "192.168.231.2";
    dns = "192.168.231.2";
    tapId = "vm-red";
    mac = "52:54:00:aa:bb:01";
    volumes = [
      {
        mountPoint = "/var";
        image = "/dev/vg_pool/vm1";
        size = 1024 * 64;
        fsType = "ext4";
      }
    ];
    vsock.cid = 4;
  };
}
