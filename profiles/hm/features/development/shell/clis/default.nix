{ pkgs, ... }:
{
  imports = [
    ./yazi.nix
  ];
  home.packages = with pkgs; [
    yazi
    fzf
    cloc
    lazygit
    devenv
    direnv
    lsd
  ];
}
