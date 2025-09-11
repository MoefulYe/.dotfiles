{ pkgs, ... }:
{
  home.packages = with pkgs; [
    swww
  ];
  services.swww.enable = true;
  xdg.configFile."wallpapers" = {
    source = "${pkgs.my-pkgs.wallpapers}";
  };
}
