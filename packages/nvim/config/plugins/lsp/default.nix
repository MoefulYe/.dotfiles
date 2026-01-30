{ lib, lite, ... }:
{
  # LSP is only enabled in full mode
  imports = lib.mkIf (!lite) [
    ./conform.nix
    ./fidget.nix
    ./lsp.nix
    ./langs
    ./dap.nix
  ];
}
