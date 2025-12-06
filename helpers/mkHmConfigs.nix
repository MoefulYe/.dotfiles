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
      userid = fullyQualifiedUserName;
    }
    // userInfo;
    system = userInfo.system or "x86_64-linux";
    isLinux = lib.strings.hasInfix "linux" system;
    isDarwin = lib.strings.hasInfix "darwin" system;
  in
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    extraSpecialArgs = specialArgs // {
      userInfo = userInfo';
      inherit isDarwin isLinux;
    };
    modules = [
      {
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
