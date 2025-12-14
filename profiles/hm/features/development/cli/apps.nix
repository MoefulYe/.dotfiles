{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yazi
    fzf
    cloc
    lazygit
    devenv
    lsd
    bat
    tlrc
    awscli2
    delta
    deploy-rs
  ];
}
