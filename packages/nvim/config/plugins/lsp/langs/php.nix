#phan
{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    phan = {
      enable = true;
      package = null;
    };
  };
}
