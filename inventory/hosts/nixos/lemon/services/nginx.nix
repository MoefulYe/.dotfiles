{
  services.nginx = {
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
}
