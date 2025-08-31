{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    xdg-utils
  ];
  xdg = {
    # enable = true;
    # userDirs.enable = true;
    terminal-exec = with config.systemProfiles.defaultApps.terminal; {
      enable = true;
      package = pkg;
      settings = {
        default = [
          entry
        ];
      };
    };
    portal = {
      enable = true;
      wlr.enable = true;
      # config.common.default = "*";
      #  extraPortals = with pkgs; [
      #    xdg-desktop-portal-gtk
      #    xdg-desktop-portal-wlr  # For Wayland protocols (screencast, etc.)
      #    # xdg-desktop-portal-gnome
      #  ];
    };
    mime =
      let
        apps = lib.mapAttrs (name: { entry, ... }: entry) config.systemProfiles.defaultApps;
      in
      with apps;
      rec {
        enable = true;
        addedAssociations = defaultApplications;
        defaultApplications = {
          "inode/directory" = file-manager;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "application/xhtml+xml" = browser;
          "application/x-xopp" = [ "com.github.xournalpp.xournalpp.desktop" ];
          "text/html" = browser;
          "text/plain" = editor;
          "text/markdown" = editor;
          "test/x-markdown" = editor;
          "application/pdf" = pdf-viewer;
          "image/jpeg" = img-viewer;
          "image/bmp" = img-viewer;
          "image/gif" = img-viewer;
          "image/jpg" = img-viewer;
          "image/pjpeg" = img-viewer;
          "image/png" = img-viewer;
          "image/tiff" = img-viewer;
          "image/webp" = img-viewer;
          "image/x-bmp" = img-viewer;
          "image/x-gray" = img-viewer;
          "image/x-icb" = img-viewer;
          "image/x-ico" = img-viewer;
          "image/x-png" = img-viewer;
          "image/x-portable-anymap" = img-viewer;
          "image/x-portable-bitmap" = img-viewer;
          "image/x-portable-graymap" = img-viewer;
          "image/x-portable-pixmap" = img-viewer;
          "image/x-xbitmap" = img-viewer;
          "image/x-xpixmap" = img-viewer;
          "image/x-pcx" = img-viewer;
          "image/svg+xml" = img-viewer;
          "image/svg+xml-compressed" = img-viewer;
          "image/vnd.wap.wbmp" = img-viewer;
          "image/x-icns" = img-viewer;
        };
      };
  };
  environment.sessionVariables = {
    # Tell apps to use Wayland
    NIXOS_OZONE_WL = "1"; # Fixes Electron apps under Wayland
    # Explicitly set the desktop portal (optional, but can help)
    XDG_CURRENT_DESKTOP = "wlroots"; # Or "sway" if Niri behaves like Sway
  };
  services.gnome.gnome-keyring.enable = true;
}
