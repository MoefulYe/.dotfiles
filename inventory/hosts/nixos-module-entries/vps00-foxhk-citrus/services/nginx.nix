{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."rsshub.059867.yxz" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:1200";
        proxyWebsockets = true;
        extraProxyHeaders = {
          "Upgrade" = "$http_upgrade";
          "Connection" = "upgrade";
        };
      };
    };
  };
}
