{ lib, ... }:
{
  osProfiles.common.bootloader = "grub";

  boot.loader.grub = {
    device = lib.mkForce "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.loader.efi = {
    canTouchEfiVariables = false;
    efiSysMountPoint = "/efi";
  };

  time.timeZone = lib.mkForce "America/Los_Angeles";

  services.timesyncd.servers = lib.mkForce [
    "time.cloudflare.com"
    "time.google.com"
    "time.nist.gov"
  ];
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;
}
