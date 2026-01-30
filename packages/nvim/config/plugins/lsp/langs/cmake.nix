{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    cmake.enable = true;
    cmake.package = null;
  };
}
