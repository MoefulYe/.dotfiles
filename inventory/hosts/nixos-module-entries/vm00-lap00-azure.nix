{
  bee = {
    address = "192.168.231.64/24";
    gateway = "192.168.231.2";
    dns = "192.168.231.2";
    tapId = "vm-azure";
    mac = "52:54:00:aa:bb:00";
    volumes = [
      {
        mountPoint = "/var";
        image = "/dev/vg_pool/vm0";
        size = 1024 * 64;
        fsType = "ext4";
      }
    ];
    vsock.cid = 3;
  };
}
