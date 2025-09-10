{ lib, config, ... }: let
  bootloader = options.osProfiles.common.baseSystem.bootloader;
in {
  options.osProfiles.common.baseSystem.bootloader = with lib; mkOption {
    type = types.enum [ "grub" "systemd-boot" "none" ];
    default = "systemd-boot";
  };
  config.boot.loader = {
    grub.enable = bootloader == "grub";
    systemd-boot.enable = bootloader == "systemd-boot";
  };
}