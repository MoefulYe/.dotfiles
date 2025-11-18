{
  hosts,
  nixpkgs,
  specialArgs,
  paths,
  ...
}:
hosts
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
          imports = extraModules ++ [ 
          "${paths.osRoles}/${hostInfo.role}"
            mainModule 
          ];
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
