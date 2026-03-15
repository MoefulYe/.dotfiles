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

  hostName = config.networking.hostName;
  hostFqdn = if domain == null then null else "${hostName}.${domain}";

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

  aliasRecordExtra = {
    proxied = false;
  };

  aliasRecords =
    if hostFqdn == null then
      [ ]
    else
      hostInfo.alias or [ ] |> builtins.map (alias: toCnameRecord alias hostFqdn aliasRecordExtra);

  expandVirtualHostName =
    name:
    if domain == null then
      name
    else if name == "@" then
      domain
    else
      "${name}.${domain}";

  expandedNginxVirtualHosts =
    cfg.nginxVirtualHosts
    |> mapAttrs' (
      name: value: {
        name = expandVirtualHostName name;
        value = {
          forceSSL = true;
          enableACME = true;
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
          proxied = true;
        }
        // getVirtualHostDnsExt name;
      in
      if domain == null then
        [ ]
      else if name == "@" then
        optionals bindHostnameToIp (toAddressRecords name recordExtra)
      else if hostFqdn == null then
        toAddressRecords name recordExtra
      else
        [ (toCnameRecord name hostFqdn recordExtra) ]
    );

  collectedRecords =
    optionals (bindHostnameToIp && domain != null) (toAddressRecords hostName hostRecordExtra)
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

    bindHostnameToIp = mkOption {
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
    networking.domain = mkDefault domain;

    assertions =
      optionals (cfg.extraRecords != [ ]) [
        {
          assertion = domain != null;
          message = "infra.dnsctl.extraRecords requires infra.dnsctl.domain to be set";
        }
      ]
      ++ cfg.nginxVirtualHosts
      |> builtins.attrNames
      |>
        builtins.map (name: {
          assertion = !(hasPrefix "~" name);
          message = "infra.nginxVirtualHosts only accepts '@' or relative names, regex names are not supported: ${name}";
        })
        ++ optionals (domain != null) (
          cfg.nginxVirtualHosts
          |> builtins.attrNames
          |> builtins.map (name: {
            assertion = name == "@" || !(name == domain || hasSuffix ".${domain}" name);
            message = "infra.nginxVirtualHosts must use '@' or relative names, not FQDNs: ${name}";
          })
        );

    services.nginx.virtualHosts = mkIf (cfg.nginxVirtualHosts != { }) expandedNginxVirtualHosts;
    infra.dnsctl.records = collectedRecords ++ cfg.extraRecords;
  };
}
