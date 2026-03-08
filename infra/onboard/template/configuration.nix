{ config, pkgs, ... }:

{
  system.stateVersion = "25.11";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    (throw "add your keys")
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

}
