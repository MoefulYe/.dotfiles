{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nur.repos.ccicnce113424.wpsoffice-365
  ];
}
