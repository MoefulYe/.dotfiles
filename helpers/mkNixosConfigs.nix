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
# |> nixpkgs.lib.filterAttrs (_: hostInfo: builtins.elem "nixos" (hostInfo.tags or [ ]))
|> builtins.mapAttrs (
  hostname: hostInfo:
  inputs.nixpkgs.lib.nixosSystem {
    system = hostInfo.system or "x86_64-linux";
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
            if !(hostInfo ? nixosConfig) then
              [
                "${paths.osRoles}/${hostInfo.role}"
              ]
            else if builtins.isPath hostInfo.nixosConfig || builtins.isString hostInfo.nixosConfig then
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
