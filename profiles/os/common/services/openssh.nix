{ lib, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false; # Disable password authentication for security
      PubkeyAuthentication = "yes"; # Enable public key authentication
      ChallengeResponseAuthentication = "no"; # Disable challenge-response authentication
    };
    ports = lib.mkDefault [ 2222 ];
  };
}
