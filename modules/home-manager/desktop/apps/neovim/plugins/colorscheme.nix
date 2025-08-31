{ inputs, ... }:
{
  disabledModules = [ "${inputs.stylix}/modules/neovim/nixos.nix" ];
  programs.nixvim.colorscheme = "catppuccin";
  programs.nixvim.colorschemes.catppuccin = {
    enable = true;
    settings = {
      background = {
        light = "frappe";
        dark = "macchiato";
      };
      custom_highlights = ''
        function(highlights)
          return {
          CursorLineNr = { fg = highlights.peach, style = {} },
          NavicText = { fg = highlights.text },
          }
        end
      '';
      flavour = "frappe"; # "latte", "mocha", "frappe", "macchiato" or raw lua code
      no_bold = false;
      no_italic = false;
      no_underline = false;
      transparent_background = false;
      integrations = {
        cmp = true;
        notify = true;
        gitsigns = true;
        neotree = true;
        which_key = true;
        illuminate = {
          enabled = true;
          lsp = true;
        };
        navic = {
          enabled = true;
          custom_bg = "NONE";
        };
        treesitter = true;
        telescope.enabled = true;
        indent_blankline.enabled = true;
        mini = {
          enabled = true;
          indentscope_color = "rosewater";
        };
        native_lsp = {
          enabled = true;
          inlay_hints = {
            background = true;
          };
          virtual_text = {
            errors = [ "italic" ];
            hints = [ "italic" ];
            information = [ "italic" ];
            warnings = [ "italic" ];
            ok = [ "italic" ];
          };
          underlines = {
            errors = [ "underline" ];
            hints = [ "underline" ];
            information = [ "underline" ];
            warnings = [ "underline" ];
          };
        };
      };
    };
  };
}
