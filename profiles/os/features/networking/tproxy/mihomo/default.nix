{
  lib,
  paths,
  config,
  pkgs,
  ...
}:

let
  cfg = config.osProfiles.features.tproxy.mihomo;
  zjuCfg = config.osProfiles.features.tproxy.extraProxies.zju-connect;
  tproxyBypassUserCfg = config.osProfiles.features.tproxy.tproxyBypassUser;
  smartdnsCfg = config.osProfiles.features.tproxy.smartdns;

  mkConfig = import ./mkConfig.nix;
  keywordFilters = import ./regionKeywords.nix;
  regionMatchRegs = keywordFilters.regionMatchRegs;
  otherRegionMatchReg = keywordFilters.otherRegionMatchReg;
  regions = keywordFilters.regions ++ [ "other-region" ];

  geoip-url = "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat";
  geosite-url = "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat";
  mmdb-url = "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb";
  bypass-fake-ip-url = "https://cdn.jsdelivr.net/gh/juewuy/ShellCrash@dev/public/fake_ip_filter.list";

  basic-config = ''
    mode: rule
    ipv6: false
    socks-port: ${builtins.toString cfg.socks5Port}
    tproxy-port: ${builtins.toString cfg.tproxyPort}
    listeners:
      - name: for-smartdns-resolve
        type: socks
        port: ${builtins.toString cfg.socks5PortForSmartDnsResolving}
        listen: 127.0.0.1
        udp: true
        proxy: DNS
    allow-lan: true
    log-level: ${cfg.logLevel}
    bind-address: "*"
    unified-delay: true
    tcp-concurrent: true
    external-controller: ":${builtins.toString cfg.externalController}"
    secret: ${config.sops.placeholder.MIHOMO_WEB_UI_PASSWD}
    global-client-fingerprint: firefox
    geodata-mode: true
    geox-url:
      geoip: "${geoip-url}"
      geosite: "${geosite-url}"
      mmdb: "${mmdb-url}"
  '';

  dns-config = ''
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
        - 127.0.0.1:${builtins.toString smartdnsCfg.foreignDnsPort}
      nameserver-policy:
        'geosite:cn':
          - 127.0.0.1:${builtins.toString smartdnsCfg.domesticDnsPort}
        'geosite:private':
          - 127.0.0.1:${builtins.toString smartdnsCfg.domesticDnsPort}
        'rule-set:zju-intranet-domain':
          - 127.0.0.1:${builtins.toString smartdnsCfg.domesticDnsPort}
        'rule-set:bypass-fake-ip':
          - 127.0.0.1:${builtins.toString smartdnsCfg.domesticDnsPort}
      proxy-server-nameserver:
          - 127.0.0.1:${builtins.toString smartdnsCfg.domesticDnsPort}
      fake-ip-filter:
        - 'geosite:cn'
        - 'geosite:private'
        - 'rule-set:zju-intranet-domain'
        - 'rule-set:bypass-fake-ip'
      fallback:
        - tls://8.8.4.4
        - tls://1.1.1.1
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

  proxies = builtins.concatLists [
    (
      lib.lists.optionals zjuCfg.enable [
        {
          name = "zju-connect";
          type = "socks5";
          server = "localhost";
          port = zjuCfg.socks5Port;
        }
      ]
    )
  ];

  rule-providers = {
    bypass-fake-ip = {
      type = "http";
      format = "text";
      url = bypass-fake-ip-url;
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

  proxy-groups-by-region = 
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
    ];

  proxy-groups = builtins.concatLists [
    proxy-groups-by-region
    (lib.lists.optionals zjuCfg.enable [
      {
        name = "ZJU";
        type = "select";
        proxies = [
          "DIRECT"
          "zju-connect"
        ];
      }
    ])
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
          "DIRECT"
        ]
        ++ regions;
      }
    ]
  ];
  rules = builtins.concatLists [
    (lib.lists.optionals zjuCfg.enable [
      "RULE-SET,zju-intranet,ZJU"
    ])
    [
      "GEOSITE,private,DIRECT,no-resolve"
      # TODO
      "GEOIP,private,DIRECT,no-resolve"
      "IP-CIDR,10.0.0.0/8,DIRECT"
      "IP-CIDR,172.16.0.0/12,DIRECT"
      "IP-CIDR,192.168.0.0/16,DIRECT"
      "GEOSITE,steam@cn,DIRECT"
      "GEOSITE,CN,DIRECT"
      "GEOIP,CN,DIRECT"
      "MATCH,universal"
    ]
  ];
in
{
  imports = [
    ./nftables
  ];
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
      dns-config
      proxies
      rules
      proxy-groups
      ;
    proxy-providers = proxy-providers';
    rule-providers = rule-providers';
  };
  systemd.services."my-mihomo" = {
    enable = true;
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
      StateDirectory = [ "mihomo" ];
      User = tproxyBypassUserCfg.name;
      Group = tproxyBypassUserCfg.name;
      LoadCredential = "mihomo.yaml:${config.sops.templates."mihomo.yaml".path}";

      ## Hardening
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
}

