{ lib, lite, ... }:
{
  imports = [
    ./colorscheme.nix
    ./treesitter.nix
    ./telescope.nix
  ] ++ lib.optionals (!lite) [
    # Full mode: development tools
    ./lsp.nix
    ./cmp.nix
    ./git.nix
    ./ui.nix
  ];
}
