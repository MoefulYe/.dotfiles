{ pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    settings = {
      indent.enable = true;
      highlight.enable = true;
    };
    folding = false;
    nixvimInjections = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      astro
      awk
      bash
      c
      cmake
      comment
      cpp
      css
      csv
      cuda
      diff
      dockerfile
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      glsl
      goctl
      godot_resource
      gomod
      gosum
      gotmpl
      gowork
      graphql
      haskell
      haskell_persistent
      helm
      hlsl
      html
      http
      ini
      java
      javadoc
      javascript
      jq
      jsdoc
      json
      json5
      jsonc
      jsonnet
      just
      kconfig
      kdl
      kitty
      llvm
      lua
      luadoc
      luap
      luau
      markdown
      markdown_inline
      mermaid
      meson
      mlir
      nginx
      ninja
      nix
      objc
      objdump
      proto
      python
      regex
      rust
      scss
      slint
      sql
      ssh_config
      toml
      tsx
      typescript
      typespec
      typoscript
      vim
      vimdoc
      vue
      yaml
      zsh
    ];
  };

  plugins.treesitter-textobjects = {
    enable = false;
    settings = {
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "ii" = "@conditional.inner";
          "ai" = "@conditional.outer";
          "il" = "@loop.inner";
          "al" = "@loop.outer";
          "at" = "@comment.outer";
        };
      };
      move = {
        enable = true;
        goto_next_start = {
          "]m" = "@function.outer";
          "]]" = "@class.outer";
        };
        goto_next_end = {
          "]M" = "@function.outer";
          "][" = "@class.outer";
        };
        goto_previous_start = {
          "[m" = "@function.outer";
          "[[" = "@class.outer";
        };
        goto_previous_end = {
          "[M" = "@function.outer";
          "[]" = "@class.outer";
        };
      };
      swap = {
        enable = true;
        swap_next = {
          "<leader>a" = "@parameters.inner";
        };
        swap_previous = {
          "<leader>A" = "@parameter.outer";
        };
      };
    };
  };
}
