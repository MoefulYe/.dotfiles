{
  helpers,
  specialArgs,
  lib,
  ...
}:
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
  home-manager.backupFileExtension = ".bak";
  home-manager.users."ashenye" =
    (helpers.mkEmbedHmConfigs {
      fullyQualifiedUserName = "ashenye@lap01-macm4-mume";
      inherit specialArgs lib;
    }).config;
}
