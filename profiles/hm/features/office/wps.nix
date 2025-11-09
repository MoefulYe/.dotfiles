{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.pkgs-25-05.wpsoffice
  ];
}
