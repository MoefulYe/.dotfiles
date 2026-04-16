{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Replace this with the target boot disk, preferably by-id.
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              size = "128G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix-store" = {
                    mountpoint = "/nix/store";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
                mountpoint = "/";
              };
            };
            lvm = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "data";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      data = {
        type = "lvm_vg";
        lvs = {
          pool = {
            size = "100%";
            lvm_type = "thin-pool";
          };
        };
      };
    };
  };
}
