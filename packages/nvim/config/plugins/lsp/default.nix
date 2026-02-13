{ lib, lite, ... }:
{
  # LSP is only enabled in full mode
  imports = lib.optionals (!lite) [
    ./conform.nix
    ./fidget.nix
    ./lsp.nix
    ./lspsaga.nix
    ./langs
    ./dap.nix
  ];
}
