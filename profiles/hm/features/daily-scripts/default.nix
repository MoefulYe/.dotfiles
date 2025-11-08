{ lib, ... }:
let
  scripts = {
    switch-to-airpods = ./switch-to-airpods;
    cleanup-bakup-files = ./cleanup-bakup-files;
    printsops = ./printsops;
    readlink-deep = ./readlink-deep;
    toggle-swayidle = ./toggle-swayidle;
    toggle-waybar = ./toggle-waybar;
    change-wallpaper = ./change-wallpaper;
  };
in
{
  home.file =
    scripts
    |> (lib.mapAttrs' (
      name: path:
      lib.nameValuePair ".local/bin/${name}" {
        source = path;
        executable = true;
      }
    ));
}
