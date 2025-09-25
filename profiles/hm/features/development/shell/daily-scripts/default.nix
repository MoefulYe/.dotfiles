let 
  scripts = {
    switch-to-airpods = ./switch-to-airpods.sh;
    cleanup-bakup-files = ./cleanup-bakup-files.sh;
  };
in {
 home.file = scripts |> (mapAttrs (name: path: { source = path; executable = true; }));
}