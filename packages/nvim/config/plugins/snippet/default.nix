{ pkgs, ... }:
{
  plugins = {
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
      fromVscode = [
        {
          # paths = "${pkgs.vimPlugins.friendly-snippets}";
          paths = "${../../snippets}";
        }
      ];
    };
  };
}
