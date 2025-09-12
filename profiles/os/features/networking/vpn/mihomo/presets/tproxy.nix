{
  lib,
  paths,
  config,
  ...
}:
let
  mkConfig = import ../helpers/mkConfig.nix;
  keywordFilters = import ../helpers/regionKeywords.nix;
  regionMatchRegs = keywordFilters.regionMatchRegs;
  otherRegionMatchReg = keywordFilters.otherRegionMatchReg;
  regions = keywordFilters.regions;
  cfg = config.services.mihomo.presets.tproxy;

  basic-config = ''
        #######################
        # mihomo basic config #
        #######################
        mode: rule
        ipv6: false
        tproxy-port: ${builtins.toString cfg.tproxyPort}
        routing-mark: ${builtins.toString cfg.routingMark}
        allow-lan: true
        log-level: ${cfg.logLevel}
        bind-address: "*"
        unified-delay: true
        tcp-concurrent: true
        external-controller: ":9090"
        secret: ${config.sops.placeholder.secret}
        profile:
          store-selected: true
          store-fake-ip: true
        global-client-fingerprint: random
        geodata-mode: true
        geox-url:
          geoip: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
          geosite: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
          mmdb: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb"
        ################################################
        # sniffer config                               #
        # ref: https://wiki.metacubex.one/config/sniff #
        ################################################
        sniffer:
          enable: true
          force-dns-mapping: false
          parse-pure-ip: true
          override-destination: false
          sniff:
            HTTP:
    ports: [80, 8080-8880]
              override-destination: true
            TLS:
              ports: [443, 8443]
            QUIC:
              ports: [443, 8443]
  '';
  proxy-providers = [
    "ikuuu"
    "leiting"
    "mojie"
    "pokemon"
  ];
  proxy-providers' =
    proxy-providers
    |> (name: {
      inherit name;
      value = {
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
      };
    })
    |> builtins.listToAttrs;
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
    anti-AD = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml";
      behavior = "domain";
    };
    anti-AD-white = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml";
      behavior = "domain";
    };
  };
  rule-providers' =
    rule-providers
    |> builtins.mapAttrs (
      name: value: with value; {
        type = "http";
        format = "yaml";
        inherit url behavior;
        path = "./rule-providers/${name}.yaml";
        interval = 3600;
      }
    );

  proxy-groups = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxy-groups)
    # 按照区域匹配的代理组
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
    # 其他地区的代理组
    [
      # 其他地区的代理组
      {
        name = "other-region";
        type = "url-test";
        use = proxy-providers;
        filter = otherRegionMatchReg;
      }
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
        name = "ad-block";
        type = "select";
        proxies = [
          "REJECT"
          "DIRECT"
          "manual"
        ];
      }
      {
        name = "AI";
        type = "url-test";
        proxies = builtins.filter (region: region != "hk") regions;
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
  ];
  rules = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.rules)
    [
      "GEOSITE,private,DIRECT,no-resolve"
      "GEOIP,private,DIRECT,no-resolve"
      "AND,((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white)))),ad-block"
      "GEOSITE,openai,AI"
      "GEOSITE,anthropic,AI"
      "GEOSITE,x,AI"
      "GEOSITE,xai,AI"
      "DOMAIN-SUFFIX,claude.ai,AI"
      "DOMAIN-SUFFIX,claudeusercontent.com,AI"
      "GEOSITE,apple,universal"
      "GEOSITE,apple-cn,universal"
      "GEOSITE,google,us"
      "GEOSITE,ehentai,universal"
      "GEOSITE,github,universal"
      "GEOSITE,twitter,universal"
      "GEOSITE,youtube,universal"
      "GEOSITE,telegram,universal"
      "GEOSITE,bahamut,universal"
      "GEOSITE,spotify,universal"
      "GEOSITE,pixiv,universal"
      "GEOSITE,steam@cn,DIRECT"
      "GEOSITE,steam,universal"
      "GEOSITE,onedrive,universal"
      "GEOSITE,microsoft,universal"
      "GEOSITE,geolocation-!cn,universal"
      # quic "AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOIP,CN))),REJECT"
      "GEOIP,telegram,universal"
      "GEOIP,twitter,universal"
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
    routingMark = mkOption {
      type = types.int;
    };
    zjuConnect = {
      enable = mkEnableOption "enable zju connect proxy";
      socks5Port = mkOption {
        type = types.int;
      };
    };
    logLevel = mkOption {
      type = types.str;
      default = "info";
    };
  };
  config = {
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = config.sops.templates."mihomo.yaml".path;
      webui = pkgs.metacubexd;
    };
    sops.secrets = {
      MIHOMO_WEB_UI_PASSWD = {
        sopsFile = "${paths.secret}/per-host/${config.osProfiles.common.hostInfo.hostname}/default.yaml";
      };
    }
    // (
      providers
      |> builtins.map (name: {
        inherit name;
        value = {
          sopsFile = "${paths.secret}/mihomo.yaml";
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
  };
}
