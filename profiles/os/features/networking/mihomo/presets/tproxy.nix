{
  lib,
  paths,
  config,
  pkgs,
  ...
}:
# 分流: https://www.aloxaf.com/2025/04/how_to_use_geosite/
let
  mkConfig = import ../helpers/mkConfig.nix;
  keywordFilters = import ../helpers/regionKeywords.nix;
  regionMatchRegs = keywordFilters.regionMatchRegs;
  otherRegionMatchReg = keywordFilters.otherRegionMatchReg;
  regions = keywordFilters.regions;
  cfg = config.services.mihomo.presets.tproxy;

  basic-config = ''
    mode: rule
    ipv6: false
    tproxy-port: ${builtins.toString cfg.tproxyPort}
    listeners:
      - name: for-smartdns-resolve
        type: socks
        port: 7894
        listen: 127.0.0.1
        udp: true
        proxy: DNS
    allow-lan: true
    # log-level: ${cfg.logLevel}
    log-level: debug
    bind-address: "*"
    unified-delay: true
    tcp-concurrent: true
    external-controller: "127.0.0.1:9090"
    secret: ${config.sops.placeholder.MIHOMO_WEB_UI_PASSWD}
    global-client-fingerprint: firefox
    geodata-mode: true
    geox-url:
      geoip: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
      geosite: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
      mmdb: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb"
    dns:
      enable: true
      cache-algorithm: arc
      prefer-h3: false
      use-hosts: true
      use-system-hosts: true
      listen: 127.0.0.1:${builtins.toString cfg.dnsPort}
      ipv6: false
      enhanced-mode: fake-ip
      fake-ip-range: 198.18.0.1/16
      nameserver:
        - 127.0.0.1:30054
      nameserver-policy:
        'geosite:cn':
          - 127.0.0.1:30053
        'geosite:private':
          - 127.0.0.1:30053
        'rule-set:zju-intranet-domain':
          - 127.0.0.1:30053
        'rule-set:bypass-fake-ip':
          - 127.0.0.1:30053
      proxy-server-nameserver:
        - 127.0.0.1:30053
      fake-ip-filter:
        - 'geosite:cn'
        - 'geosite:private'
        - 'rule-set:zju-intranet-domain'
        - 'rule-set:bypass-fake-ip'
  '';
  proxy-providers = [
    # "ikuuu"
    "leiting"
    "mojie"
    # "av1"
    # "pokemon"
  ];
  proxy-providers' = lib.attrsets.genAttrs proxy-providers (name: {
    type = "http";
    interval = 3600;
    health-check = {
      enable = true;
      url = "https://cp.cloudflare.com";
      interval = 300;
      timeout = 1000;
      tolerance = 100;
    };
    path = "./proxy-providers/${name}.yaml";
    url = config.sops.placeholder."${name}";
    override = {
      udp = true;
      additional-prefix = "[${name}] ";
    };
  });
  zju = {
    enable = cfg.zjuConnect.enable;
    proxies = [
      {
        name = "zju-connect";
        type = "socks5";
        server = "localhost";
        port = cfg.zjuConnect.socks5Port;
      }
    ];
    proxy-groups = [
      {
        name = "ZJU";
        type = "select";
        proxies = [
          "DIRECT"
          "zju-connect"
        ];
      }
    ];
    rules = [ "IP-CIDR,10.0.0.0/8,ZJU" ];
  };
  proxies = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxies)
  ];
  rule-providers = {
    bypass-fake-ip = {
      type = "http";
      format = "text";
      url = "https://cdn.jsdelivr.net/gh/juewuy/ShellCrash@dev/public/fake_ip_filter.list";
    };
    zju-intranet-domain = {
      behavior = "domain";
      type = "inline";
      payload = [
        "www.cc98.org"
      ];
    };
    zju-intranet = {
      behavior = "ipcidr";
      type = "inline";
      payload = [
        "10.0.0.0/8"
      ];
    };
  };
  rule-providers' =
    rule-providers
    |> builtins.mapAttrs (
      name: value: (
        if value.type == "http" 
        then {
          behavior = "domain";
          path = "./rule-providers/${name}";
          interval = 86400;
        } // value 
        else value
      )
    );

  proxy-groups = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxy-groups)
    # 按照区域匹配的代理组
    (
      (
        regionMatchRegs
        |> (builtins.mapAttrs (
          name: filter: {
            inherit name filter;
            type = "url-test";
            use = proxy-providers;
          }
        ))
        |> builtins.attrValues
      )
      ++ [
        # 其他地区的代理组
        {
          name = "other-region";
          type = "url-test";
          use = proxy-providers;
          filter = otherRegionMatchReg;
        }
      ]
    )
    # 规则特定的代理组
    # [
    #   {
    #     name = "ad-block";
    #     type = "select";
    #     proxies = [
    #       "REJECT"
    #       "DIRECT"
    #       "manual"
    #     ];
    #   }
    #   {
    #     name = "GOOGLE";
    #     type = "select";
    #     use = proxy-providers;
    #     proxies = [
    #       "auto-fast"
    #       "manual"
    #       "all"
    #       "other-region"
    #       "DIRECT"
    #     ]
    #     ++ regions;

    #   }
    #   {
    #     name = "GITHUB";
    #     type = "select";
    #     use = proxy-providers;
    #     proxies = [
    #       "auto-fast"
    #       "manual"
    #       "all"
    #       "other-region"
    #       "DIRECT"
    #     ]
    #     ++ regions;
    #   }
    #   {
    #     name = "AI";
    #     type = "select";
    #     use = proxy-providers;
    #     proxies = [
    #       "auto-fast"
    #       "us"
    #       "manual"
    #       "all"
    #       "other-region"
    #       "DIRECT"
    #     ]
    #     ++ regions;
    #   }
    #   {
    #     name = "AISTUDIO";
    #     type = "select";
    #     use = proxy-providers;
    #     proxies = [
    #       "auto-fast"
    #       "us"
    #       "manual"
    #       "all"
    #       "other-region"
    #       "DIRECT"
    #     ]
    #     ++ regions;
    #   }
    # ]
    [
      {
        name = "all";
        type = "url-test";
        use = proxy-providers;
      }
      {
        name = "auto-fast";
        type = "url-test";
        use = proxy-providers;
        tolerance = 2;
      }
      {
        name = "manual";
        type = "select";
        proxies = regions ++ [
          "all"
          "auto-fast"
          "DIRECT"
        ];
      }
      {
        name = "universal";
        type = "select";
        proxies = [
          "auto-fast"
          "manual"
          "all"
          "other-region"
          "DIRECT"
        ]
        ++ regions;
      }
    ]
    [
      {
        name = "DNS";
	      type = "fallback";
	      proxies = [
	        "universal"
	        "DIRECT"
	      ];
	      url = "https://www.gstatic.com/generate_204";
	      interval = 300;
      }
    ]
  ];
  rules = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.rules)
    [
      # "IP-CIDR,10.0.0.0/8,DIRECT"
      # "IP-CIDR,172.16.0.0/12,DIRECT"
      # "IP-CIDR,192.168.0.0/16,DIRECT"
      "GEOSITE,private,DIRECT,no-resolve"
      "GEOIP,private,DIRECT,no-resolve"
      # "AND,((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white)))),ad-block"
      # "GEOSITE,openai,AI"
      # "GEOSITE,anthropic,AI"
      # "GEOSITE,x,AI"
      # "GEOSITE,xai,AI"
      # "DOMAIN-SUFFIX,aistudio.google.com,AISTUDIO"
      # "DOMAIN-SUFFIX,claude.ai,AI"
      # "DOMAIN-SUFFIX,claudeusercontent.com,AI"
      # "GEOSITE,apple,universal"
      # "GEOSITE,apple-cn,universal"
      # "GEOSITE,google,GOOGLE"
      # "GEOSITE,ehentai,universal"
      # "GEOSITE,github,GITHUB"
      # "GEOSITE,twitter,universal"
      # "GEOSITE,youtube,universal"
      # "GEOSITE,telegram,universal"
      # "GEOSITE,bahamut,universal"
      # "GEOSITE,spotify,universal"
      # "GEOSITE,pixiv,universal"
      "GEOSITE,steam@cn,DIRECT"
      # "GEOSITE,steam,universal"
      # "GEOSITE,onedrive,universal"
      # "GEOSITE,microsoft,universal"
      # "GEOSITE,geolocation-!cn,universal"
      # "DOMAIN-SUFFIX,bing.com,DIRECT"
      # "DOMAIN-SUFFIX,gstatic.com,GOOGLE"
      # "DOMAIN-SUFFIX,googleapis.com,GOOGLE"
      # quic "AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOIP,CN))),REJECT"
      # "GEOIP,telegram,universal"
      # "GEOIP,twitter,universal"
      "GEOSITE,CN,DIRECT"
      "GEOIP,CN,DIRECT"
      "MATCH,universal"
    ]
  ];
in
with lib;
{
  options.services.mihomo.presets.tproxy = {
    tproxyPort = mkOption {
      type = types.int;
      default = 7895;
    };
    dnsPort = mkOption {
      type = types.int;
      default = 7853;
    };
    zjuConnect = {
      enable = mkEnableOption "enable zju connect proxy";
      socks5Port = mkOption {
        type = types.int;
        default = 0;
      };
    };
    logLevel = mkOption {
      type = types.str;
      default = "warning";
    };
    uid = mkOption {
      type = types.int;
      default = 61382;
    };
  };
  config = {
    sops.secrets = {
      MIHOMO_WEB_UI_PASSWD = {
        sopsFile = "${paths.secrets}/per-host/${config.osProfiles.common.hostInfo.hostname}/default.yaml";
      };
    }
    // (
      proxy-providers
      |> builtins.map (name: {
        inherit name;
        value = {
          sopsFile = "${paths.secrets}/mihomo.yaml";
        };
      })
      |> builtins.listToAttrs
    );
    sops.templates."mihomo.yaml".content = mkConfig {
      inherit
        lib
        basic-config
        proxies
        rules
        proxy-groups
        ;
      proxy-providers = proxy-providers';
      rule-providers = rule-providers';
    };
    users = {
      users.mihomo = {
        group = "mihomo";
        isNormalUser = true;
        inherit (cfg) uid;
      };
      groups.mihomo = { };
    };
    systemd.services."my-mihomo" = {
      enable = true;
      description = "Mihomo daemon, A rule-based proxy in Go.";
      documentation = [ "https://wiki.metacubex.one/" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.mihomo}/bin/mihomo"
          "-d /var/lib/mihomo"
          "-f \${CREDENTIALS_DIRECTORY}/mihomo.yaml"
          "-ext-ui ${pkgs.metacubexd}"
        ];

        StateDirectory = "mihomo";
        User = "mihomo";
        Group = "mihomo";
        LoadCredential = "mihomo.yaml:${config.sops.templates."mihomo.yaml".path}";

        ### Hardening
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service bpf";
        UMask = "0077";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        PrivateDevices = false;
        PrivateUsers = false;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
      };
    };
  };
}
