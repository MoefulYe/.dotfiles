{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yazi
    fzf
    cloc
    lazygit
    devenv
    direnv
  ];
}
