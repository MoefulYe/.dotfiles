{
  specialArgs,
  hostInfo,
  inventory,
  ...
}:
let
  hostname = hostInfo.hostname;
in
{
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771113;
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771113;
        HIDKeyboardModifierMappingDst = 30064771129;
      }
    ];
  };
  home-manager =
    let
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
              "${specialArgs.path.hmRoles}/${userInfo.role}"
            ]
          else
            userInfo.hmConfig.extra
            ++ [
              "${specialArgs.path.hmRoles}/${userInfo.role}"
              userInfo.hmConfig.main
            ];
        home.username = username;
      };
    };
}
