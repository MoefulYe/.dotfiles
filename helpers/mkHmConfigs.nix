{
  hmUsers,
  nixpkgs,
  specialArgs,
  ...
}:
hmUsers
|> builtins.mapAttrs (
  hostname:
  {
    mainModule,
    extraModules ? [ ],
    hostInfo,
  }:
  nixpkgs.lib.nixosSystem {
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
