{ paths, lib, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    # "${osProfiles}/features/virtualisation/k8s/slave.nix"
  ];
  networking.hosts = {
    "127.0.0.2" = lib.mkForce [ "vm03-lap00-black" ];
    "192.168.231.67" = [
      "vm03-lap00-black.void"
      "vm03-lap00-black"
    ];
  };
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
    mem = 1024 * 5;
    vsock.cid = 6;
  };
}
