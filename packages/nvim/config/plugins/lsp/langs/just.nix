{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    just = {
      enable = true;
    };
  };
}
