{
  fullyQualifiedUserName,
  specialArgs,
  lib,
  ...
}:
let
  userInfo = specialArgs.inventory.users.${fullyQualifiedUserName};
  splitFullyQualifiedUsername = import ./splitFullyQualifiedUsername.nix;
  inherit
    (splitFullyQualifiedUsername {
      inherit lib fullyQualifiedUserName;
    })
    username
    hostname
    ;
  userInfo' = {
    inherit username hostname;
    userid = fullyQualifiedUserName;
  }
  // userInfo;
  isLinux = lib.strings.hasInfix "linux" (userInfo.system or "x86_64-linux");
  isDarwin = !isLinux;
in
lib.evalModules {
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
            "${specialArgs.path.hmRoles}/${userInfo.role}"
          ]
        else
          userInfo.hmConfig.extra
          ++ [
            "${specialArgs.path.hmRoles}/${userInfo.role}"
            userInfo.hmConfig.main
          ];
      home.username = username;
    }
  ];
}
