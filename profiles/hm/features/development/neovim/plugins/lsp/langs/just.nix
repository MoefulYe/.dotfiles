{ lib, pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers = {
      just = {
        enable = true;
      };
    };
  };
}
