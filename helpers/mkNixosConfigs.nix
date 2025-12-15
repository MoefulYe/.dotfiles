{
  hosts,
  nixpkgs,
  specialArgs,
  paths,
  ...
}:
hosts
|> nixpkgs.lib.filterAttrs (_: hostInfo: builtins.elem "nixos" (hostInfo.tags or [ ]))
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
      isDarwin = false;
      isLinux = true;
    };
    modules = [
      (
        { hostInfo, ... }:
        {
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
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
