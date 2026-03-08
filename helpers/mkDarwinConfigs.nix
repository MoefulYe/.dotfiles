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
            if hostInfo ? darwinConfig then
              [
                "${paths.osRoles}/${hostInfo.role}"
              ]
            else if builtins.isPath hostInfo.darwinConfig || builtins.isString hostInfo.darwinConfig then
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
