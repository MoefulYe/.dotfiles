{
  hosts,
  nixpkgs,
  specialArgs,
  paths,
  nix-darwin,
  ...
}:
hosts
|> nixpkgs.lib.filterAttrs (_: hostInfo: builtins.elem "darwin" (hostInfo.tags or [ ]))
|> builtins.mapAttrs (
  hostname: hostInfo:
  nix-darwin.lib.darwinSystem {
    system = hostInfo.system;
    specialArgs = specialArgs // {
      hostInfo = {
        inherit hostname;
        hostid = hostname;
      }
      // hostInfo;
      isDarwin = true;
      isLinux = false;
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
