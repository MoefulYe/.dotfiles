{
  lib,
  config,
  options,
  hostInfo,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    drop
    filter
    hasInfix
    hasPrefix
    hasSuffix
    listToAttrs
    mapAttrs'
    mkDefault
    mkIf
    mkOption
    optional
    optionals
    removeSuffix
    splitString
    take
    types
    ;

  cfg = config.infra.dnsctl;

  normalizeAddressList =
    value:
    if value == null then
      [ ]
    else if builtins.isList value then
      value
    else
      [ value ];

  ipv4Values = normalizeAddressList cfg.ipv4;
  ipv6Values = normalizeAddressList cfg.ipv6;

  domain = if cfg.domain == null || cfg.domain == "" then null else cfg.domain;
  subdomain = if cfg.subdomain == null || cfg.subdomain == "" then null else cfg.subdomain;
  fqdnDomain =
    if domain == null then
      null
    else if subdomain == null then
      domain
    else
      "${subdomain}.${domain}";

  qualifyRecordName =
    name:
    if subdomain == null then
      name
    else if name == "@" then
      subdomain
    else
      "${name}.${subdomain}";

  hostName = config.networking.hostName;
  hostRecordName = qualifyRecordName hostName;
  hostFqdn = if domain == null then null else "${hostRecordName}.${domain}";

  nginxVirtualHostElemType = options.services.nginx.virtualHosts.type.nestedTypes.elemType;
  nginxVirtualHostSubOptions = builtins.removeAttrs (nginxVirtualHostElemType.getSubOptions [ ]) [
    "_module"
  ];

  nginxVirtualHostType = types.attrsOf (
    types.submodule {
      options = nginxVirtualHostSubOptions // {
        forceSSL = nginxVirtualHostSubOptions.forceSSL // {
          default = true;
        };
        enableACME = nginxVirtualHostSubOptions.enableACME // {
          default = true;
        };
        dnsRecordExt = mkOption {
          type = types.attrsOf types.anything;
          default = { };
        };
      };
    }
  );

  toAddressRecords =
    name: extra:
    optionals (ipv4Values != [ ]) [
      (
        {
          inherit name;
          type = "A";
          values = ipv4Values;
        }
        // extra
      )
    ]
    ++ optionals (ipv6Values != [ ]) [
      (
        {
          inherit name;
          type = "AAAA";
          values = ipv6Values;
        }
        // extra
      )
    ];

  toCnameRecord =
    name: value: extra:
    {
      inherit name;
      type = "CNAME";
      values = [ value ];
    }
    // extra;

  hostRecordExtra = {
    proxied = false;
  };

  bindHostnameToIp = cfg.bindHostnameToIp;
  nginxVirtualHostsProxied = cfg.nginxVirtualHostsProxied;
  nginxVirtualHostsUseSSL = cfg.nginxVirtualHostsUseSSL;

  aliasRecordExtra = {
    proxied = false;
  };

  aliasRecords =
    if hostFqdn == null then
      [ ]
    else
      hostInfo.alias or [ ]
      |> builtins.map (alias: toCnameRecord (qualifyRecordName alias) hostFqdn aliasRecordExtra);

  expandVirtualHostName =
    name:
    if fqdnDomain == null then
      name
    else if name == "@" then
      fqdnDomain
    else
      "${name}.${fqdnDomain}";

  expandedNginxVirtualHosts =
    cfg.nginxVirtualHosts
    |> mapAttrs' (
      name: value: {
        name = expandVirtualHostName name;
        value = {
          forceSSL = nginxVirtualHostsUseSSL;
          enableACME = nginxVirtualHostsUseSSL;
        }
        // builtins.removeAttrs value [ "dnsRecordExt" ];
      }
    );

  virtualHostNames = cfg.nginxVirtualHosts |> builtins.attrNames;

  getVirtualHostDnsExt = name: cfg.nginxVirtualHosts.${name}.dnsRecordExt or { };

  virtualHostRecords =
    virtualHostNames
    |> builtins.concatMap (
      name:
      let
        recordExtra = {
          proxied = nginxVirtualHostsProxied;
        }
        // getVirtualHostDnsExt name;
      in
      if domain == null then
        [ ]
      else if name == "@" then
        optionals bindHostnameToIp (toAddressRecords (qualifyRecordName name) recordExtra)
      else if hostFqdn == null then
        toAddressRecords (qualifyRecordName name) recordExtra
      else
        [ (toCnameRecord (qualifyRecordName name) hostFqdn recordExtra) ]
    );

  collectedRecords =
    optionals (bindHostnameToIp && domain != null) (toAddressRecords hostRecordName hostRecordExtra)
    ++ aliasRecords
    ++ virtualHostRecords;

  dnsRecordType = types.submodule {
    freeformType = types.attrsOf types.anything;
    options = {
      name = mkOption {
        type = types.str;
      };
      type = mkOption {
        type = types.str;
      };
      values = mkOption {
        type = types.listOf types.str;
      };
    };
  };
in
{
  options.infra.dnsctl = {
    ipv4 = mkOption {
      type = types.nullOr (types.either types.str (types.listOf types.str));
      default = null;
    };

    ipv6 = mkOption {
      type = types.nullOr (types.either types.str (types.listOf types.str));
      default = null;
    };

    nginxVirtualHosts = mkOption {
      type = nginxVirtualHostType;
      default = { };
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    subdomain = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    bindHostnameToIp = mkOption {
      type = types.bool;
      default = true;
    };

    nginxVirtualHostsProxied = mkOption {
      type = types.bool;
      default = true;
    };

    nginxVirtualHostsUseSSL = mkOption {
      type = types.bool;
      default = true;
    };

    extraRecords = mkOption {
      type = types.listOf dnsRecordType;
      default = [ ];
    };

    records = mkOption {
      type = types.listOf dnsRecordType;
      readOnly = true;
      internal = true;
    };
  };

  config = {
    networking.domain = mkDefault fqdnDomain;

    assertions =
      let
        nginxVirtualHostNames = builtins.attrNames cfg.nginxVirtualHosts;
      in
      optionals (cfg.extraRecords != [ ]) [
        {
          assertion = domain != null;
          message = "infra.dnsctl.extraRecords requires infra.dnsctl.domain to be set";
        }
      ]
      ++ builtins.map (name: {
        assertion = !(hasPrefix "~" name);
        message = "infra.nginxVirtualHosts only accepts '@' or relative names, regex names are not supported: ${name}";
      }) nginxVirtualHostNames
      ++ optionals (domain != null) (
        builtins.map (name: {
          assertion = name == "@" || !(name == domain || hasSuffix ".${domain}" name);
          message = "infra.nginxVirtualHosts must use '@' or relative names, not FQDNs: ${name}";
        }) nginxVirtualHostNames
      );

    services.nginx.virtualHosts = mkIf (cfg.nginxVirtualHosts != { }) expandedNginxVirtualHosts;
    infra.dnsctl.records = collectedRecords ++ cfg.extraRecords;
  };
}
