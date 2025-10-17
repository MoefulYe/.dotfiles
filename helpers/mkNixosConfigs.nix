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
    hostInfo ? { },
  }:
  nixpkgs.lib.nixosSystem {
    system = hostInfo.system;
    specialArgs = specialArgs // {
      hostInfo = hostInfo // {
        inherit hostname;
      };
    };
    modules = [
      (
        { hostInfo, ... }:
        {
          imports = extraModules ++ [ mainModule ];
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
