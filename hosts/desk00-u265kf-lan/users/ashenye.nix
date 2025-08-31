{ config, ... }:
{
  imports = [
    ../../../modules/home-manager
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/quirk-patches/link-gnome-terminal-to-kitty.nix
  ];
  config.userProfiles = {
    username = "ashenye";
    homeDirectory = "/home/ashenye";
    email = "luren145@gmail.com";
    enableZjuLabSsh = true;
  };
}
