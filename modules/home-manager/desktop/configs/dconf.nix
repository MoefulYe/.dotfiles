{ pkgs, ... }:
{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
        event-sounds = false;
      };
      "org/gnome/desktop/interface/color-scheme" = {
        default = "prefer-dark";
      };
    };
  };
  home.packages = with pkgs; [
    dconf
  ];
}
