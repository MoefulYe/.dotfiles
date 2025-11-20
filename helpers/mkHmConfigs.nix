{
  users,
  specialArgs,
  home-manager,
  nixpkgs,
  paths,
  ...
}:
users
|> builtins.mapAttrs (
  fullyQualifiedUserName: userInfo:
  let
    lib = nixpkgs.lib;
    splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
    inherit (splitFullyQualifiedUsername { inherit lib fullyQualifiedUserName; }) username hostname;
    userInfo' = {
      inherit username hostname;
    }
    // userInfo;
  in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages."${userInfo'.system or "x86_64-linux"}";
    extraSpecialArgs = specialArgs // {
      userInfo = userInfo';
    };
    modules = [
      {
        # imports = extraModules ++ [ "${paths.hmRoles}/${userInfo.role}"
        #   mainModule
        # ];
        imports =
          if builtins.isPath userInfo.hmConfig || builtins.isString userInfo.hmConfig then
            [
              userInfo.hmConfig
              "${paths.hmRoles}/${userInfo.role}"
            ]
          else
            userInfo.hmConfig.extra
            ++ [
              "${paths.hmRoles}/${userInfo.role}"
              userInfo.hmConfig.main
            ];
        home.username = username;
      }
    ];
  }
)
