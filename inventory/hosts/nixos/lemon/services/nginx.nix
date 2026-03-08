{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."one.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8080";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "luren145@gmail.com";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
