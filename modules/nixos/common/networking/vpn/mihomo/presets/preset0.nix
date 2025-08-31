{
  lib,
  tproxy-port ? 7895,
  routing-mark,
  log-level ? "info",
  external-controller ? ":9090",
  external-controller-secret ? null,
  proxy-providers, # attrs of provider-url
  rule-providers ? {
    anti-AD = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml";
      behavior = "domain";
    };
    anti-AD-white = {
      url = "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml";
      behavior = "domain";
    };
  },
  zju-connect-cfg ? {
    enable = false;
    socks5Port = 31080;
  },
}:
let
  mkMihomo = import ../mkMihomo.nix;
  keywordFilters = import ../snippets/keywords.nix;
  regionMatchRegs = keywordFilters.regionMatchRegs;
  otherRegionMatchReg = keywordFilters.otherRegionMatchReg;
  regions = keywordFilters.regions;
  zju = {
    enable = zju-connect-cfg.enable;
    proxies = [
      {
        name = "zju-connect";
        type = "socks5";
        server = "localhost";
        port = zju-connect-cfg.socks5Port;
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
  mapAttrsValues = fn: attrs: builtins.attrValues (builtins.mapAttrs fn attrs);
  proxy-providers' = builtins.mapAttrs (name: url: {
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
    inherit url;
    override = {
      udp = true;
      additional-prefix = "[${name}] ";
    };
  }) proxy-providers;
  proxy-provider-names = builtins.attrNames proxy-providers;
  rule-providers' = builtins.mapAttrs (
    name: value: with value; {
      type = "http";
      format = "yaml";
      inherit url behavior;
      path = "./rule-providers/${name}.yaml";
      interval = 3600;
    }
  ) rule-providers;
  proxies = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxies)
  ];
  proxy-groups = builtins.concatLists [
    (lib.lists.optionals zju.enable zju.proxy-groups)
    # 按照区域匹配的代理组
    (mapAttrsValues (name: filter: {
      inherit name filter;
      type = "url-test";
      use = proxy-provider-names;
    }) regionMatchRegs)
    # 其他地区的代理组
    [
      # 其他地区的代理组
      {
        name = "other-region";
        type = "url-test";
        use = proxy-provider-names;
        filter = otherRegionMatchReg;
      }
      {
        name = "all";
        type = "url-test";
        use = proxy-provider-names;
      }
      {
        name = "auto-fast";
        type = "url-test";
        use = proxy-provider-names;
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
      "GEOSITE,google,AI"
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
      "GEOIP,google,universal"
      "GEOIP,telegram,universal"
      "GEOIP,twitter,universal"
      "GEOSITE,CN,DIRECT"
      "GEOIP,CN,DIRECT"
      "MATCH,universal"
    ]
  ];
in
mkMihomo {
  inherit
    lib
    tproxy-port
    routing-mark
    log-level
    external-controller
    external-controller-secret
    ;
  ipv6 = false;
  allow-lan = true;
  inherit proxies proxy-groups rules;
  proxy-providers = proxy-providers';
  rule-providers = rule-providers';
}
