{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/features/virtualisation/k8s/slave.nix"
  ];
  bee = {
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
    vcpu = 4;
    mem = 4096;
    vsock.cid = 5;
  };
}
