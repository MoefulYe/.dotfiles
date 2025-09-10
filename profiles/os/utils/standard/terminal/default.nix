{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    zellij
    zsh
    vim
    less
    bash
  ];
}