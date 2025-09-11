{ lib, pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers = {
      cmake.enable = true;
      cmake.package = null;
    };
  };
}
