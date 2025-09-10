{
  pkgs,
  lib,
  config,
  ...
}:
{
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
  # virtualisation.docker.enable = true;
  # users.users."ashenye".extraGroups = [ "docker" ];

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    #docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];
}
