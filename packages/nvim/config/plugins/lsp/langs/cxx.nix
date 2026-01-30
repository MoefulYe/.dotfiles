{ lib, pkgs, ... }:
{

  plugins.lsp.servers = {
    clangd = {
      enable = true;
      # 在项目环境中配置clangd
      package = null;
      settings = {
        cmd = [
          "clangd"
          "--background-index"
          "--clang-tidy"
          "--header-insertion=iwyu"
        ];
        root_markers = [
          "compile_commands.json"
          "compile_flags.txt"
        ];
      };
    };
  };
  plugins.clangd-extensions.enable = true;
  plugins.conform-nvim = {
    settings = {
      formatters_by_ft = {
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
      };
      formatters = {
        clang-format = {
          command = "clang-format";
        };
      };
    };
  };
}
