{
  config,
  pkgs,
  me,
  ...
}:
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

  infra.dnsctl.nginxVirtualHosts = {
    jellyfin.locations."/" = {
      proxyPass = "http://localhost:38083";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      extraConfig = ''
        return 444;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = me.email;
  };
}
