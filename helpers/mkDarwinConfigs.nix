{
  paths,
  inputs,
  ...
}:
{
  hosts,
  specialArgs,
  ...
}:
hosts
|> inputs.nixpkgs.lib.filterAttrs (_: hostInfo: builtins.elem "darwin" (hostInfo.tags or [ ]))
|> builtins.mapAttrs (
  hostname: hostInfo:
  inputs.nix-darwin.lib.darwinSystem {
    system = hostInfo.system or "aarch64-darwin";
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
            let
              roleConfigs = if hostInfo ? role then [ "${paths.osRoles}/${hostInfo.role}" ] else [ ];
              darwinConfigs =
                if !(hostInfo ? darwinConfig) then
                  [ ]
                else if builtins.isPath hostInfo.darwinConfig || builtins.isString hostInfo.darwinConfig then
                  [
                    hostInfo.darwinConfig
                  ]
                else
                  hostInfo.darwinConfig.extra
                  ++ [
                    hostInfo.darwinConfig.main
                  ];
            in
            darwinConfigs ++ roleConfigs;
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
