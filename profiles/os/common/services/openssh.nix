{ lib, isLinux, ... }:
{
  services.openssh =
    if isLinux then
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
        # FIXME: 好像没有起到效果?
        extraConfig = ''
          PermitRootLogin no
          PasswordAuthentication no
          PubkeyAuthentication yes
          ChallengeResponseAuthentication no
          Port 2222
        '';
      };
}
