{ paths, lib, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    # "${osProfiles}/features/virtualisation/k8s/slave.nix"
  ];
  networking.hosts = {
    "127.0.0.2" = lib.mkForce [ "vm02-lap00-white" ];
    "192.168.231.66" = [
      "vm02-lap00-white.void"
      "vm02-lap00-white"
    ];
  };
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
    mem = 1024 * 5;
    vsock.cid = 5;
  };
}
