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
    virtualHosts."blog.pippaye.top" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/blog.pippaye.top";
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          # 静态资源缓存优化
          expires 7d;
          add_header Cache-Control "public, immutable" always;

          # 安全头部
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      locations."~* \\.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$" = {
        extraConfig = ''
          # 静态资源长期缓存
          expires 30d;
          add_header Cache-Control "public, immutable" always;
          access_log off;

          # 安全头部
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      locations."~* \\.(html|xml|json)$" = {
        extraConfig = ''
          # HTML/XML/JSON 短期缓存
          expires 1h;
          add_header Cache-Control "public, must-revalidate" always;

          # 安全头部
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Referrer-Policy "no-referrer-when-downgrade" always;
        '';
      };
      extraConfig = ''
        # 禁止访问隐藏文件
        location ~ /\. {
          deny all;
          access_log off;
          log_not_found off;
        }
      '';
    };
  };
}
