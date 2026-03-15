{
  virtualisation.docker.enable = true;
  users.users.ashenye.extraGroups = [ "docker" ];

  infra.dnsctl.nginxVirtualHosts = {
    rsshub.locations."/" = {
      proxyPass = "http://localhost:1200";
    };

    miniflux.locations."/" = {
      proxyPass = "http://localhost:10080";
    };

    n8n.locations."/" = {
      proxyPass = "http://localhost:5678";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
        client_max_body_size 50M;
      '';
    };

    bark.locations."/" = {
      proxyPass = "http://localhost:18080";
    };

    bitwarden.locations."/" = {
      proxyPass = "http://localhost:8222";
      proxyWebsockets = true;
    };

    firefly.locations."/" = {
      proxyPass = "http://localhost:8081";
    };

    blog = {
      root = "/var/www/blog.pippaye.top";
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          expires 7d;
          add_header Cache-Control "public, immutable" always;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      locations."~* \\.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$" = {
        extraConfig = ''
          expires 30d;
          add_header Cache-Control "public, immutable" always;
          access_log off;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      locations."~* \\.(html|xml|json)$" = {
        extraConfig = ''
          expires 1h;
          add_header Cache-Control "public, must-revalidate" always;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      extraConfig = ''
        location ~ /\. {
          deny all;
          access_log off;
          log_not_found off;
        }
      '';
    };
  };
}
