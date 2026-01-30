{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    nil_ls = {
      enable = true;
    };
  };
  plugins.conform-nvim = {
    settings = {
      formatters_by_ft = {
        nix = [ "nixfmt-rfc-style" ];
      };
      formatters = {
        nixfmt-rfc-style = {
          command = "${lib.getExe pkgs.nixfmt-rfc-style}";
        };
      };
    };
  };
}
