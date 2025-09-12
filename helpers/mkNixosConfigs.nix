{
  nixosHosts,
  nixpkgs,
  specialArgs,
  ...
}:
nixosHosts
|> builtins.mapAttrs (
  hostname:
  { nixosModuleEntry, hostInfo }:
  nixpkgs.lib.nixosSystem {
    system = hostInfo.system;
    inherit specialArgs;
    modules = [
      {
        imports = [
          nixosModuleEntry
        ];
        config.osProfiles.common.hostInfo.hostname = hostname;
        config.networking.hostName = hostname;
      }
    ];
  }
)
