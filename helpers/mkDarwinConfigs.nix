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
  nixpkgs.lib.darwinSystem {
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
          imports =
            if builtins.isPath hostInfo.darwinConfig || builtins.isString hostInfo.darwinConfig then
              [
                hostInfo.darwinConfig
                "${paths.osRoles}/${hostInfo.role}"
              ]
            else
              hostInfo.darwinConfig.extra
              ++ [
                hostInfo.darwinConfig.main
                "${paths.osRoles}/${hostInfo.role}"
              ];
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
