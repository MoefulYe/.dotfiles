{ pkgs, ... }:
{
  # for fun
  home.packages = with pkgs; [
    cool-crt-term
    fastfetch
    aafire
    cmatrix
    aalib
  ];
}
