{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niri
    xwayland-satellite
  ];
  programs.niri.enable = true;
  programs.sway.enable = true;
  # programs.hyprland.enable = true;
  programs.xwayland.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };
  services = {
    gvfs.enable = true;
    devmon.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    accounts-daemon.enable = true;
  };
}
