{
  lib,
  systemProfiles,
  config,
  ...
}:
let
  apps = lib.mapAttrs (name: value: value.binname) systemProfiles.defaultApps;
in
{
  home.sessionVariables = with apps; {
    EDITOR = editor;
    VISUAL = editor;
    BROWSER = browser;
    TERMINAL = terminal;
  };
}
