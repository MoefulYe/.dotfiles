{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    pyright = {
      enable = true;
      package = null;
    };
  };
  plugins.conform-nvim = {
    settings = {
      formatters_by_ft = {
        python = [
          "ruff_fix"
          "ruff_format"
          "ruff_organize_imports"
        ];
      };
    };
  };
}
