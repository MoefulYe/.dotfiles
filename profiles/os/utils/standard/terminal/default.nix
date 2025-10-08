{ pkgs, ... }:
{
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    zellij
    zsh
    vim
    less
    bash
  ];
}
