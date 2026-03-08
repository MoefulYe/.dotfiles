{ lib, pkgs, ... }:
{

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  osProfiles.common.bootloader = "grub";
  boot.loader.grub.device = "/dev/vda";
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.ports = [ 22 ];

  services.timesyncd.servers = lib.mkForce null;
  time.timeZone = "America/Los_Angeles";
}
