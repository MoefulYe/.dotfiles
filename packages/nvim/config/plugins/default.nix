{ lib, lite, ... }:
{
  imports = [
    ./colorscheme.nix
    ./treesitter.nix
    ./telescope.nix
  ] ++ lib.optionals (!lite) [
    # Full mode: all development tools
    ./lsp
    ./cmp
    ./git
    ./ui
    ./editor
    ./utils
    ./snippet
  ];
}
