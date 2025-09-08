{ lib, config, ... }:
let
  inherit (config.systemProfiles.features.openssh) enable PasswordAuthentication;
in
{
  services.openssh = {
    inherit enable;
    settings = {
      PermitRootLogin = "no";
      inherit PasswordAuthentication; # Disable password authentication for security
      PubkeyAuthentication = "yes"; # Enable public key authentication
      ChallengeResponseAuthentication = "no"; # Disable challenge-response authentication
    };
    ports = [ 2222 ];
  };
}
