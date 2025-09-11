{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    niri
    xwayland-satellite
  ];
  programs.niri.enable = true;
  programs.sway.enable = true;
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
  environment.sessionVariables = {
    # Tell apps to use Wayland
    NIXOS_OZONE_WL = "1"; # Fixes Electron apps under Wayland
    # Explicitly set the desktop portal (optional, but can help)
    XDG_CURRENT_DESKTOP = "wlroots"; # Or "sway" if Niri behaves like Sway
  };
}
