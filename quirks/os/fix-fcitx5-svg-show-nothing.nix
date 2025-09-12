{ pkgs, lib, ... }:
{
  programs.gdk-pixbuf.modulePackages = lib.mkDefault [ pkgs.librsvg ];
}
