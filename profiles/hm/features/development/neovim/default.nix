{
  config,
  lib,
  pkgs,
  outputs,
  ...
}:
let
  cfg = config.hmProfiles.my-nvim;
in
{
  options.hmProfiles.my-nvim = {
    lite = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable lite mode for low-resource devices
        Lite mode includes:
        - Basic editing features
        - Config file syntax highlighting (json, yaml, toml, xml, ini, bash, nix)
        - Simple file search (telescope)
        - Lightweight colorscheme

        Full mode adds:
        - LSP support
        - Code completion
        - Git integration
        - AI tools (Copilot)
        - UI plugins
      '';
    };
  };

  config = {
    home.packages = [
      (if cfg.lite then pkgs.my-pkgs.nvim-lite else pkgs.my-pkgs.nvim)
    ];
  };
}
