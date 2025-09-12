{
  nixosHosts,
  nixpkgs,
  specialArgs,
  ...
}:
nixosHosts
|> builtins.mapAttrs (
  hostname:
  {
    mainModule,
    extraModules ? [ ],
    hostInfo,
  }:
  nixpkgs.lib.nixosSystem {
    system = hostInfo.system;
    inherit specialArgs;
    modules = [
      {
        imports = extraModules ++ [ mainModule ];
        config.osProfiles.common.hostInfo.hostname = hostname;
        config.networking.hostName = hostname;
      }
    ];
  }
)
