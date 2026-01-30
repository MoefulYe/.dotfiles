{ lib, lite, ... }:
{
  # Both modes use catppuccin
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "frappe";
      transparent_background = false;

      # Full mode: enable integrations
      integrations = lib.mkIf (!lite) {
        cmp = true;
        gitsigns = true;
        telescope.enabled = true;
        treesitter = true;
        native_lsp.enabled = true;
      };
    };
  };
}
