{
  config,
  pkgs,
  ...
}:
let
  cfg = config.hmProfiles.dev;
in
{
  config = {
    home.packages = [
      (if cfg.lite then pkgs.my-pkgs.nvim-lite else pkgs.my-pkgs.nvim)
    ];
  };
}
