{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kitty
    pkgs.my-pkgs.gnome-terminal
  ];
}
