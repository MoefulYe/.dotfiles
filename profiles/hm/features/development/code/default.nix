{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.hmProfiles.dev;
in
{
  home.packages = lib.mkIf cfg.daily (
    with pkgs;
    [
      vscode
    ]
  );
}
