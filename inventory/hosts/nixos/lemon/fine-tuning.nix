{ lib, ... }:
{
  osProfiles.common.bootloader = "grub";

  time.timeZone = lib.mkForce "America/Los_Angeles";

  services.timesyncd.servers = lib.mkForce [
    "time.cloudflare.com"
    "time.google.com"
    "time.nist.gov"
  ];
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;
}
