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
  options.hmProfiles.dev = {
    lite = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = {
    home.packages =
      with pkgs;
      [
        lsd
        cloc
        bat
        tlrc
        delta
        fzf
      ]
      ++ (lib.optionals (!cfg.lite) [
        yazi
        lazygit
        devenv
        awscli2
        deploy-rs
      ]);
  };
}
