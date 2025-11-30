{ lib, pkgs, ... }:
{
  services.openssh =
    if pkgs.stdenv.isLinux then
      {
        enable = lib.mkDefault true;
        settings = {
          PermitRootLogin = lib.mkDefault "no";
          PasswordAuthentication = lib.mkDefault false; # Disable password authentication for security
          PubkeyAuthentication = "yes"; # Enable public key authentication
          ChallengeResponseAuthentication = "no"; # Disable challenge-response authentication
        };
        ports = lib.mkDefault [ 2222 ];
      }
    else
      {
        enable = lib.mkDefault true;
        extraConfig = ''
          PermitRootLogin no
          PasswordAuthentication no
          PubkeyAuthentication yes
          ChallengeResponseAuthentication no
          Port 2222
        '';
      };
}
