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
        name = "desk00-u265kf-lan";
        stateVersion = "24.11";
        type = "desktop";
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
      openssh = {
        enable = true;
        PasswordAuthentication = true;
      };
      virtualisation = {
        podman = {
          enable = true;
        };
      };
    };
  };
  config.networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
  config.users.users."lab-guest" = {
    isNormalUser = true;
    createHome = true;
  };
}
