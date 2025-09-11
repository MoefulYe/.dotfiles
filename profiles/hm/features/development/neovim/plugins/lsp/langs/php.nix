#phan
{ lib, pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers = {
      phan = {
        enable = true;
        package = null;
      };
    };
  };
}
