{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."rsshub.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:1200";
      };
    };
    virtualHosts."miniflux.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:10080";
      };
    };
    virtualHosts."n8n.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
          client_max_body_size 50M;
        '';
      };
    };
    virtualHosts."bark.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:18080";
      };
    };
  };
}
