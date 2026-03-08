{
  inputs,
  paths,
  ...
}:
{
  users,
  specialArgs,
  ...
}:
users
|> builtins.mapAttrs (
  fullyQualifiedUserName: userInfo:
  let
    lib = inputs.nixpkgs.lib;
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
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    extraSpecialArgs = specialArgs // {
      userInfo = userInfo';
      inherit isDarwin isLinux;
    };
    modules = [
      {
        imports =
          let
            roleConfigs =
              if userInfo ? role then
                [
                  "${paths.hmRoles}/${userInfo.role}"
                ]
              else
                [ ];
            hmConfigs =
              if !(userInfo ? hmConfig) then
                roleConfigs
              else if builtins.isPath userInfo.hmConfig || builtins.isString userInfo.hmConfig then
                [
                  userInfo.hmConfig
                ]
                ++ roleConfigs
              else
                userInfo.hmConfig.extra
                ++ roleConfigs
                ++ [
                  userInfo.hmConfig.main
                ];
          in
          hmConfigs;
        home.username = username;
      }
    ];
  }
)
