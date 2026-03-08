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
  system.defaults.CustomUserPreferences = {
    "NSGlobalDomain" = {
      # 设置为 true：F1-F12 作为标准功能键
      # 设置为 false：F1-F12 作为媒体控制键（默认）
      "com.apple.keyboard.fnState" = true;
    };
  };
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
}
