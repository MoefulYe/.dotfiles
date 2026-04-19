{
  config,
  pkgs,
  me,
  paths,
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
      useACMEHost = "zjucst.pippaye.top";
    };
    calibre.locations."/" = {
      proxyPass = "http://localhost:38084";
      useACMEHost = "zjucst.pippaye.top";
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

  sops.secrets."CF_PIPPAYE_ZONE_EDIT_TOKEN" = {
    owner = "acme";
    mode = "0400";
    sopsFile = "${paths.secrets}/api-tokens.yaml";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = me.email;
    certs."zjucst.pippaye.top" = {
      domain = "zjucst.pippaye.top";
      extraDomainNames = [ "*.zjucst.pippaye.top" ];
      dnsProvider = "cloudflare";
      environmentFile = "/var/run/secrets/CF_PIPPAYE_ZONE_EDIT_TOKEN";
      dnsPropagationCheck = true;
    };
  };

  services.calibre-web = {
    enable = true;
    listen.port = 38084;
  };
}
