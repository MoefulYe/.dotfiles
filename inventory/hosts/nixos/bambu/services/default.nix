{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.users.ashenye.extraGroups = [ "docker" ];
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 38081;
    package = pkgs.qbittorrent-enhanced-nox;
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.qbittorrent.serviceConfig.Slice =
    config.osProfiles.features.tproxy.tproxyBypass.sliceName;
}
