{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];
}
