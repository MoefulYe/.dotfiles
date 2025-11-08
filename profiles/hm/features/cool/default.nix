{ pkgs, ... }:
{
  # for fun
  home.packages = with pkgs; [
    cool-retro-term
    fastfetch
    cmatrix
    aalib
  ];
}
