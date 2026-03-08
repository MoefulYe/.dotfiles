{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "25.11";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.ports = [ 22 ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
}
