{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.systemProfiles.features.virtualisation.podman.enable {
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        # Required for containers under podman-compose to be able to talk to each other.
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # Useful other development tools
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      #docker-compose # start group of containers for dev
      podman-compose # start group of containers for dev
    ];
  };
}
