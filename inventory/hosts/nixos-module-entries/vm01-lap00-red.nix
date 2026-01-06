{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/features/virtualisation/k8s/master.nix"
  ];
  bee = {
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
    mem = 1024 + 512;
  };
}
