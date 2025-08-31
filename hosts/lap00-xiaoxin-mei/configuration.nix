{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nixos
    ../../modules/nixos/desktop
    ../../modules/nixos/quirk-patches/fix-fn-keys.nix
    ../../modules/nixos/quirk-patches/fix-fcitx5-svg-show-nothing.nix
    ../../modules/nixos/quirk-patches/unsafe-openssl-dingtalk.nix
  ];
  config.systemProfiles = {
    basic = {
      host = {
        name = "lap00-xiaoxin-mei";
        stateVersion = "24.11";
        type = "laptop";
      };
      users = {
        hmModules = {
          ashenye = import ./users/ashenye.nix;
        };
      };
    };
    features = {
      mihomo = {
        enable = true;
        enableWebUI = true;
      };
      enableAutoGC = true;
    };
  };
}
