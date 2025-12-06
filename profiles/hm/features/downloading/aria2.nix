{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ariang
    aria2
  ];
}
