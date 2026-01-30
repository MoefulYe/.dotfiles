{ lib, lite, ... }:
{
  plugins.telescope = {
    enable = true;

    keymaps = lib.mkMerge [
      # Lite mode: minimal keymaps
      {
        "<leader>f" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>/" = {
          action = "live_grep";
          options.desc = "Search in files";
        };
        "<leader>b" = {
          action = "buffers";
          options.desc = "Buffers";
        };
      }

      # Full mode: additional keymaps
      (lib.mkIf (!lite) {
        "<C-p>" = {
          action = "git_files";
          options.desc = "Git files";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help";
        };
      })
    ];
  };
}
