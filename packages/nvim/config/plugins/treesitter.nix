{ pkgs, lib, lite, ... }:
{
  plugins.treesitter = {
    enable = true;
    settings = {
      indent.enable = true;
      highlight.enable = true;
    };

    grammarPackages = if lite then
      # Lite: only config file languages
      with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        comment
        diff
        git_config
        ini
        json
        lua
        markdown
        markdown_inline
        nix
        regex
        toml
        vim
        vimdoc
        xml
        yaml
      ]
    else
      # Full: all grammars (default)
      pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };
}
