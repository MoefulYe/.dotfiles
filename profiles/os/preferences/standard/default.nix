{ pkgs, lib, ... }:
{
  users.defaultUserShell = lib.mkIf pkgs.stdenv.isLinux pkgs.bash;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
