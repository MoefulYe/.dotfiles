{
  isLinux,
  lib,
  pkgs,
  ...
}:
{
  users.defaultUserShell = lib.mkIf isLinux pkgs.bash;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
