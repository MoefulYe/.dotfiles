{
  specialArgs,
  paths,
  hostInfo,
  inventory,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];
  home-manager =
    let
      hostname = hostInfo.hostname;
      username = "ashenye";
      fullyQualifiedUserName = "ashenye@${hostname}";
      userInfo = inventory.users.${fullyQualifiedUserName};
      userInfo' = {
        inherit username hostname;
        userid = fullyQualifiedUserName;
      }
      // userInfo;
      extraSpecialArgs = specialArgs // {
        isDarwin = true;
        isLinux = false;
        userInfo = userInfo';
      };
    in
    {
      backupFileExtension = ".bak";
      inherit extraSpecialArgs;
      users."ashenye" = {
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
      };
    };
}
