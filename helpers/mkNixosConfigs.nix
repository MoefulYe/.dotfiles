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
      }
      // hostInfo;
    };
    modules = [
      (
        { hostInfo, ... }:
        {
          imports =
            if builtins.isPath hostInfo.nixosConfig || builtins.isString hostInfo.nixosConfig then
              [ hostInfo.nixosConfig ]
            else
              [
                hostInfo.nixosConfig.main
              ]
              ++ hostInfo.nixosConfig.extra;
          config.networking.hostName = hostInfo.hostname;
        }
      )
    ];
  }
)
