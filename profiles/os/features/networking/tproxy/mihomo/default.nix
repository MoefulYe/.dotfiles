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
      listen: :${builtins.toString cfg.dnsPort}
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
    "av1"
    "fanyun"
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
    (lib.lists.optionals zjuCfg.enable [
      {
        name = "zju-connect";
        type = "socks5";
        server = "localhost";
        port = zjuCfg.socks5Port;
      }
    ])
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
    bt-download = {
      behavior = "classical";
      type = "inline";
      payload = [
        "PROCESS-NAME,qbittorrent"
      ];
    };
    github = {
      behavior = "classical";
      type = "inline";
      payload = [
        "DOMAIN-SUFFIX,atom.io"
        "DOMAIN-SUFFIX,dependabot.com"
        "DOMAIN-SUFFIX,ghcr.io"
        "DOMAIN-SUFFIX,git.io"
        "DOMAIN-SUFFIX,github-atom-io-herokuapp-com.freetls.fastly.net"
        "DOMAIN-SUFFIX,github-avatars.oss-cn-hongkong.aliyuncs.com"
        "DOMAIN-SUFFIX,github-cloud.s3.amazonaws.com"
        "DOMAIN-SUFFIX,github.blog"
        "DOMAIN-SUFFIX,github.com"
        "DOMAIN-SUFFIX,github.community"
        "DOMAIN-SUFFIX,github.dev"
        "DOMAIN-SUFFIX,github.io"
        "DOMAIN-SUFFIX,githubapp.com"
        "DOMAIN-SUFFIX,githubassets.com"
        "DOMAIN-SUFFIX,githubcopilot.com"
        "DOMAIN-SUFFIX,githubhackathon.com"
        "DOMAIN-SUFFIX,githubnext.com"
        "DOMAIN-SUFFIX,githubpreview.dev"
        "DOMAIN-SUFFIX,githubstatus.com"
        "DOMAIN-SUFFIX,githubuniverse.com"
        "DOMAIN-SUFFIX,githubusercontent.com"
        "DOMAIN-SUFFIX,myoctocat.com"
        "DOMAIN-SUFFIX,npm.community"
        "DOMAIN-SUFFIX,npmjs.com"
        "DOMAIN-SUFFIX,npmjs.org"
        "DOMAIN-SUFFIX,opensource.guide"
        "DOMAIN-SUFFIX,rawgit.com"
        "DOMAIN-SUFFIX,rawgithub.com"
        "DOMAIN-SUFFIX,repo.new"
        "DOMAIN-SUFFIX,thegithubshop.com"
        "DOMAIN-KEYWORD,github"
      ];
    };
    # https://linux.do/t/topic/688182
    ai-service = {
      behavior = "classical";
      type = "inline";
      payload = [
        # Rule count: 151
        # Last updated: 2025-05-29T03:44:19.294164
        "DOMAIN-KEYWORD,DOMAIN,ai.google.dev"
        "DOMAIN-KEYWORD,DOMAIN,alkalicore-pa.clients6.google.com"
        "DOMAIN-KEYWORD,DOMAIN,alkalimakersuite-pa.clients6.google.com"
        "DOMAIN-KEYWORD,DOMAIN,api.github.com"
        "DOMAIN-KEYWORD,DOMAIN,api.githubcopilot.com"
        "DOMAIN-KEYWORD,DOMAIN,api.individual.githubcopilot.com"
        "DOMAIN-KEYWORD,DOMAIN,api.msn.com"
        "DOMAIN-KEYWORD,DOMAIN,api.statsig.com"
        "DOMAIN-KEYWORD,DOMAIN,apple-relay.apple.com"
        "DOMAIN-KEYWORD,DOMAIN,apple-relay.cloudflare.com"
        "DOMAIN-KEYWORD,DOMAIN,assets.msn.com"
        "DOMAIN-KEYWORD,DOMAIN,bard.google.com"
        "DOMAIN-KEYWORD,DOMAIN,browser-intake-datadoghq.com"
        "DOMAIN-KEYWORD,DOMAIN,cdn.usefathom.com"
        "DOMAIN-KEYWORD,DOMAIN,chat.openai.com.cdn.cloudflare.net"
        "DOMAIN-KEYWORD,DOMAIN,copilot-proxy.githubusercontent.com"
        "DOMAIN-KEYWORD,DOMAIN,copilot.microsoft.com"
        "DOMAIN-KEYWORD,DOMAIN,gateway.ai.cloudflare.com"
        "DOMAIN-KEYWORD,DOMAIN,gateway.bingviz.microsoft.net"
        "DOMAIN-KEYWORD,DOMAIN,gateway.bingviz.microsoftapp.net"
        "DOMAIN-KEYWORD,DOMAIN,gemini.google.com"
        "DOMAIN-KEYWORD,DOMAIN,in.appcenter.ms"
        "DOMAIN-KEYWORD,DOMAIN,location.microsoft.com"
        "DOMAIN-KEYWORD,DOMAIN,makersuite.google.com"
        "DOMAIN-KEYWORD,DOMAIN,o33249.ingest.sentry.io"
        "DOMAIN-KEYWORD,DOMAIN,odc.officeapps.live.com"
        "DOMAIN-KEYWORD,DOMAIN,openai-api.arkoselabs.com"
        "DOMAIN-KEYWORD,DOMAIN,openaicom-api-bdcpf8c6d2e9atf6.z01.azurefd.net"
        "DOMAIN-KEYWORD,DOMAIN,openaicomproductionae4b.blob.core.windows.net"
        "DOMAIN-KEYWORD,DOMAIN,opilot.microsoft.com"
        "DOMAIN-KEYWORD,DOMAIN,production-openaicom-storage.azureedge.net"
        "DOMAIN-KEYWORD,DOMAIN,r.bing.com"
        "DOMAIN-KEYWORD,DOMAIN,self.events.data.microsoft.com"
        "DOMAIN-KEYWORD,DOMAIN,servd-anthropic-website.b-cdn.net"
        "DOMAIN-KEYWORD,DOMAIN,services.bingapis.com"
        "DOMAIN-KEYWORD,DOMAIN,static.cloudflareinsights.com"
        "DOMAIN-KEYWORD,DOMAIN,sydney.bing.com"
        "DOMAIN-KEYWORD,DOMAIN,www.bing.com"
        "DOMAIN-KEYWORD,aistudio"
        "DOMAIN-KEYWORD,alkalimakersuite-pa.clients6.google.com"
        "DOMAIN-KEYWORD,anthropic"
        "DOMAIN-KEYWORD,chatgpt"
        "DOMAIN-KEYWORD,claude"
        "DOMAIN-KEYWORD,cohere"
        "DOMAIN-KEYWORD,colab"
        "DOMAIN-KEYWORD,copilot"
        "DOMAIN-KEYWORD,developerprofiles"
        "DOMAIN-KEYWORD,generativelanguage"
        "DOMAIN-KEYWORD,groq"
        "DOMAIN-KEYWORD,hcompany"
        "DOMAIN-KEYWORD,openai"
        "DOMAIN-KEYWORD,openaicom-api"
        "DOMAIN-SUFFIX,AI.com"
        "DOMAIN-SUFFIX,Anthropic.com"
        "DOMAIN-SUFFIX,ai.com"
        "DOMAIN-SUFFIX,aisandbox-pa.googleapis.com"
        "DOMAIN-SUFFIX,aistudio.google.com"
        "DOMAIN-SUFFIX,algolia.net"
        "DOMAIN-SUFFIX,anthropic.com"
        "DOMAIN-SUFFIX,api.microsoftapp.net"
        "DOMAIN-SUFFIX,api.statsig.com"
        "DOMAIN-SUFFIX,apis.google.com"
        "DOMAIN-SUFFIX,auth0.com"
        "DOMAIN-SUFFIX,auth0.openai.com"
        "DOMAIN-SUFFIX,azureedge.net"
        "DOMAIN-SUFFIX,azurefd.net"
        "DOMAIN-SUFFIX,bard.google.com"
        "DOMAIN-SUFFIX,bing-shopping.microsoft-falcon.io"
        "DOMAIN-SUFFIX,bing.com"
        "DOMAIN-SUFFIX,cdn.auth0.com"
        "DOMAIN-SUFFIX,cdn.oaistatic.com"
        "DOMAIN-SUFFIX,challenges.cloudflare.com"
        "DOMAIN-SUFFIX,chat.com"
        "DOMAIN-SUFFIX,chat.groq.com"
        "DOMAIN-SUFFIX,chatgpt.com"
        "DOMAIN-SUFFIX,chatgpt.livekit.cloud"
        "DOMAIN-SUFFIX,ciciai.com"
        "DOMAIN-SUFFIX,civitai.com"
        "DOMAIN-SUFFIX,claude.ai"
        "DOMAIN-SUFFIX,client-api.arkoselabs.com"
        "DOMAIN-SUFFIX,clipdrop.co"
        "DOMAIN-SUFFIX,codeium.com"
        "DOMAIN-SUFFIX,codeiumdata.com"
        "DOMAIN-SUFFIX,console.groq.com"
        "DOMAIN-SUFFIX,coze.com"
        "DOMAIN-SUFFIX,deepmind.com"
        "DOMAIN-SUFFIX,deepmind.google"
        "DOMAIN-SUFFIX,dify.ai"
        "DOMAIN-SUFFIX,edgeservices.bing.com"
        "DOMAIN-SUFFIX,events.statsigapi.net"
        "DOMAIN-SUFFIX,featuregates.org"
        "DOMAIN-SUFFIX,geller-pa.googleapis.com"
        "DOMAIN-SUFFIX,gemini.google.com"
        "DOMAIN-SUFFIX,generativeai.google"
        "DOMAIN-SUFFIX,generativelanguage.googleapis.com"
        "DOMAIN-SUFFIX,github.dev"
        "DOMAIN-SUFFIX,googleai.com"
        "DOMAIN-SUFFIX,googleapis.com"
        "DOMAIN-SUFFIX,grazie.ai"
        "DOMAIN-SUFFIX,grazie.aws.intellij.net"
        "DOMAIN-SUFFIX,grok.com"
        "DOMAIN-SUFFIX,groq.com"
        "DOMAIN-SUFFIX,hcaptcha.com"
        "DOMAIN-SUFFIX,hcompany.ai"
        "DOMAIN-SUFFIX,host.livekit.cloud"
        "DOMAIN-SUFFIX,identrust.com"
        "DOMAIN-SUFFIX,intercom.cdn.com"
        "DOMAIN-SUFFIX,intercom.io"
        "DOMAIN-SUFFIX,intercomcdn.com"
        "DOMAIN-SUFFIX,invoice.stripe.com"
        "DOMAIN-SUFFIX,jasper.ai"
        "DOMAIN-SUFFIX,klingai.com"
        "DOMAIN-SUFFIX,labs.google"
        "DOMAIN-SUFFIX,launchdarkly.com"
        "DOMAIN-SUFFIX,lmsys.org"
        "DOMAIN-SUFFIX,makersuite.google.com"
        "DOMAIN-SUFFIX,meta.ai"
        "DOMAIN-SUFFIX,microsoft.com"
        "DOMAIN-SUFFIX,mistral.ai"
        "DOMAIN-SUFFIX,notebooklm.google"
        "DOMAIN-SUFFIX,notebooklm.google.com"
        "DOMAIN-SUFFIX,oaistatic.com"
        "DOMAIN-SUFFIX,oaiusercontent.com"
        "DOMAIN-SUFFIX,observeit.net"
        "DOMAIN-SUFFIX,openai.com"
        "DOMAIN-SUFFIX,openaiapi-site.azureedge.net"
        "DOMAIN-SUFFIX,openaicom.imgix.net"
        "DOMAIN-SUFFIX,openart.ai"
        "DOMAIN-SUFFIX,opendns.com"
        "DOMAIN-SUFFIX,opera-api.com"
        "DOMAIN-SUFFIX,pay.openai.com"
        "DOMAIN-SUFFIX,perplexity.ai"
        "DOMAIN-SUFFIX,platform.openai.com"
        "DOMAIN-SUFFIX,poe.com"
        "DOMAIN-SUFFIX,proactivebackend-pa.googleapis.com"
        "DOMAIN-SUFFIX,recaptcha.net"
        "DOMAIN-SUFFIX,segment.io"
        "DOMAIN-SUFFIX,sentry.io"
        "DOMAIN-SUFFIX,sfx.ms"
        "DOMAIN-SUFFIX,sider.ai"
        "DOMAIN-SUFFIX,sora.com"
        "DOMAIN-SUFFIX,statsigapi.net"
        "DOMAIN-SUFFIX,stripe.com"
        "DOMAIN-SUFFIX,turn.livekit.cloud"
        "DOMAIN-SUFFIX,x.ai"
        "IP-ASN,14061,no-resolve"
        "IP-ASN,20473,no-resolve"
        "IP-CIDR,24.199.123.28/32,no-resolve"
        "IP-CIDR,64.23.132.171/32,no-resolve"
      ];
    };
  };

  rule-providers' =
    rule-providers
    |> builtins.mapAttrs (
      name: value:
      (
        if value.type == "http" then
          {
            behavior = "domain";
            path = "./rule-providers/${name}";
            interval = 86400;
          }
          // value
        else
          value
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
        name = "all-exclude-hk";
        type = "url-test";
        use = proxy-providers;
        exclude-filter = regionMatchRegs.hk;
      }
      {
        name = "auto-fast-exclude-hk";
        type = "url-test";
        use = proxy-providers;
        tolerance = 2;
        exclude-filter = regionMatchRegs.hk;
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
        name = "manual-ai";
        type = "select";
        use = proxy-providers;
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
      {
        name = "GITHUB";
        type = "select";
        proxies = [
          "universal"
          "manual"
          "DIRECT"
        ]
        ++ regions;
      }
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
      {
        name = "AI";
        type = "select";
        proxies = [
          "auto-fast-exclude-hk"
          "all-exclude-hk"
          "manual-ai"
          "DIRECT"
        ]
        ++ regions;
      }
    ]
    proxy-groups-by-region
  ];
  rules = builtins.concatLists [
    (lib.lists.optionals zjuCfg.enable [
      "RULE-SET,zju-intranet,ZJU"
    ])
    [
      "GEOSITE,private,DIRECT,no-resolve"
      "GEOIP,private,DIRECT,no-resolve"
      "IP-CIDR,10.0.0.0/8,DIRECT"
      "IP-CIDR,172.16.0.0/12,DIRECT"
      "IP-CIDR,192.168.0.0/16,DIRECT"
      "GEOSITE,steam@cn,DIRECT"
      "GEOSITE,CN,DIRECT"
      "GEOIP,CN,DIRECT"
      "RULE-SET,github,GITHUB"
      "RULE-SET,ai-service,AI"
      "RULE-SET,bt-download,DIRECT"
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
