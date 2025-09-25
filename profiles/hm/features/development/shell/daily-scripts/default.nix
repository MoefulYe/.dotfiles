{ lib, ... }: let 
  scripts = {
    switch-to-airpods = ./switch-to-airpods.sh;
    cleanup-bakup-files = ./cleanup-bakup-files.sh;
  };
in {
 home.file = scripts |> (lib.mapAttrs' (name: path: lib.nameValuePair ".local/bin/${name}" { source = path; executable = true; }));
}