{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    busybox
    git
    sops
    age
  ];
}
