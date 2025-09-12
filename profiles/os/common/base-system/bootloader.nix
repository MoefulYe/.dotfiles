{ lib, config, ... }:
let
  bootloader = config.osProfiles.common.bootloader;
in
{
  options.osProfiles.common.bootloader =
    with lib;
    mkOption {
      type = types.enum [
        "grub"
        "systemd-boot"
        "none"
      ];
      default = "systemd-boot";
    };
  config.boot.loader = {
    grub.enable = bootloader == "grub";
    systemd-boot.enable = bootloader == "systemd-boot";
    efi.canTouchEfiVariables = true;
  };
}
