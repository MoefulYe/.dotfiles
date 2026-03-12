{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.loader.efi.canTouchEfiVariables = false;
  # osProfiles.common.bootloader = "grub";
  # boot.loader.grub = {
  #   device = "nodev";
  #   efiSupport = true;
  #   useOSProber = true;
  #   gfxmodeEfi = "1024x768";
  #   efiInstallAsRemovable = true;
  # };
}
