{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  # use systemd-boot default
  disko.devices = {
    disk = {
      main = {
        # TODO
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # UEFI 分区 (ESP)
            boot = {
              name = "boot";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            # 根分区 (XFS)
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
                # 如果需要额外的 XFS 挂载选项，可以在此添加
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
