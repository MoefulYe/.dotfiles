{
  bee = {
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
    vcpu = 4;
    mem = 4096;
    vsock.cid = 6;
  };
}
