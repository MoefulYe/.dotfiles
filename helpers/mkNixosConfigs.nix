{
  hosts,
  nixpkgs,
  specialArgs,
  paths,
  ...
}:
hosts
|> builtins.mapAttrs (
  hostname: hostInfo:
  nixpkgs.lib.nixosSystem {
    system = hostInfo.system;
    specialArgs = specialArgs // {
      hostInfo = {
        inherit hostname;
        hostid = hostname;
      }
      // hostInfo;
    };
    modules = [
      (
        { hostInfo, ... }:
        {
<<<<<<< HEAD
          imports =
            if builtins.isPath hostInfo.nixosConfig || builtins.isString hostInfo.nixosConfig then
              [
                hostInfo.nixosConfig
                "${paths.osRoles}/${hostInfo.role}"
              ]
            else
              hostInfo.nixosConfig.extra
              ++ [
                hostInfo.nixosConfig.main
                "${paths.osRoles}/${hostInfo.role}"
              ];
=======
          imports = extraModules ++ [ 
          "${paths.osRoles}/${hostInfo.role}"
            mainModule 
          ];
>>>>>>> ec25090 (x)
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
