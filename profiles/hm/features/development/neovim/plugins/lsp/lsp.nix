{ pkgs, lib, ... }:
{
  programs.nixvim = {
    plugins = {
      lsp-lines = {
        enable = true;
      };
      lsp-format = {
        enable = true;
      };
      lsp = {
        enable = true;
        inlayHints = true;

        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gr = {
              action = "references";
              desc = "Goto References";
            };
            gD = {
              action = "declaration";
              desc = "Goto Declaration";
            };
            gI = {
              action = "implementation";
              desc = "Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "Type Definition";
            };
            K = {
              action = "hover";
              desc = "Hover";
            };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
          };
          diagnostic = {
            "<leader>cd" = {
              action = "open_float";
              desc = "Line Diagnostics";
            };
            # "<S_Tab>" = {
            #   action = "goto_next";
            #   desc = "Next Diagnostic";
            # };
            # "<Tab>" = {
            #   action = "goto_prev";
            #   desc = "Previous Diagnostic";
            # };
          };
        };
      };
    };

    extraConfigLua = ''
            local _border = "rounded"

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
              vim.lsp.handlers.hover, {
                border = _border
              }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
              vim.lsp.handlers.signature_help, {
                border = _border
              }
            )

            vim.diagnostic.config{
              float={border=_border}
            };

            require('lspconfig.ui.windows').default_options = {
              border = _border
            }
            local cmp = require('cmp')

      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, {"i", "s"}),
          
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {'i', 's'}),
          ["<C-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }, { "i" }),
        }
      })
    '';
  };
}
