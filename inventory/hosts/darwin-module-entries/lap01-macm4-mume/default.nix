{
  specialArgs,
  paths,
  hostInfo,
  inventory,
  inputs,
  pkgs,
  ...
}:
let
  hostname = hostInfo.hostname;
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];
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
  users.users."ashenye" = {
    shell = pkgs.zsh;
    home = "/Users/ashenye";
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
