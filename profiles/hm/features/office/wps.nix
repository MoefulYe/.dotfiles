{ pkgs, ... }:
{
  home.packages = [
    pkgs.pkgs-stable.wpsoffice-cn
    # pkgs.nur.repos.chillcicada.ttf-wps-fonts
  ];
}
