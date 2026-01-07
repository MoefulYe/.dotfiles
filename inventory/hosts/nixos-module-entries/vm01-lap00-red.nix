{ paths, lib, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/features/virtualisation/k8s/master.nix"
  ];
  networking.hosts = {
    "127.0.0.2" = lib.mkForce [ "vm01-lap00-red" ];
    "192.168.231.65" = [ "vm01-lap00-red.void" "vm01-lap00-red" "red.void" ];
  };
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
