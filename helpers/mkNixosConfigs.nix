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
            let

              nixosConfigs =
                if !(hostInfo ? nixosConfig) then
                  [ ]
                else if builtins.isPath hostInfo.nixosConfig || builtins.isString hostInfo.nixosConfig then
                  [
                    hostInfo.nixosConfig
                  ]
                else
                  hostInfo.nixosConfig.extra
                  ++ [
                    hostInfo.nixosConfig.main
                  ];
              roleConfigs = if hostInfo ? role then [ "${paths.osRoles}/${hostInfo.role}" ] else [ ];
            in
            nixosConfigs ++ roleConfigs;
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
