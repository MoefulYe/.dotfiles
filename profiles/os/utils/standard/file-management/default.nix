{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rsync
    file
    tree
    fd
  ];
}
