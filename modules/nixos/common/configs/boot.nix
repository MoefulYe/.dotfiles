{ pkgs, ... }:
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    gfxmodeEfi = "1024x768";
    efiInstallAsRemovable = true;
  };
  # boot.loader.systmd-boot.enable = true;
}
