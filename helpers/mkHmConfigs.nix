{
  hmUsers,
  hosts,
  specialArgs,
  home-manager,
  nixpkgs,
  ...
}:
hmUsers
|> builtins.mapAttrs (
  fullyQualifiedUserName:
  {
    mainModule,
    extraModules ? [ ],
    userInfo ? { },
  }:
  let
    lib = nixpkgs.lib;
    splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
    inherit (splitFullyQualifiedUsername { inherit lib fullyQualifiedUserName; }) username hostname;
    hostInfo = hosts."${hostname}".hostInfo or { };
  in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages."${hostInfo.system or "x86_64-linux"}";
    extraSpecialArgs = specialArgs // {
      inherit
        fullyQualifiedUserName
        username
        hostname
        ;
      hostInfo = hostInfo // {
        inherit hostname;
      };
      userInfo = userInfo // {
        inherit username;
      };
    };
    modules = [
      {
        imports = extraModules ++ [ mainModule ];
        home.username = username;
      }
    ];
  }
)
