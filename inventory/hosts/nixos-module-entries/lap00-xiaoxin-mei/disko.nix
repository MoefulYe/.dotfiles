{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1"; # <- 改成你的硬盘
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
                extraArgs = [
                  "-n"
                  "EFI"
                ]; # FAT label
              };
            };

            swap = {
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = false;
                # 这里会用 mkswap -L swap
                extraArgs = [
                  "-L"
                  "swap"
                ];
              };
            };

            btrfs = {
              size = "80G";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "noatime"
                      "compress=zstd:3"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "noatime"
                      "compress=zstd:3"
                      "space_cache=v2"
                      # /nix 是否加 discard=async 看你习惯；不加也完全OK
                    ];
                  };

                  # 服务器如果你想把 /var 单独隔离（便于快照策略/清理），可以打开：
                  # "@var" = {
                  #   mountpoint = "/var";
                  #   mountOptions = [
                  #     "noatime"
                  #     "compress=zstd:3"
                  #     "space_cache=v2"
                  #     "discard=async"
                  #   ];
                  # };
                };
              };
            };

            lvm = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "vg_pool";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg_pool = {
        type = "lvm_vg";
        lvs = {
          # 这里我默认不创建 LV，留给你以后按需分配（VM盘/数据盘）
          # 如果你想现在就创建一个 data 盘（比如挂 /srv），取消注释：
          #
          # lv_srv = {
          #   size = "200GiB";
          #   content = {
          #     type = "filesystem";
          #     format = "ext4";
          #     mountpoint = "/srv";
          #     mountOptions = [ "noatime" ];
          #   };
          # };
        };
      };
    };
  };
}
