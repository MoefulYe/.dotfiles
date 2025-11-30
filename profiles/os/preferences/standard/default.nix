{
  isLinux,
  lib,
  pkgs,
  ...
}:
{
  users = lib.mkIf isLinux {
    defaultUserShell = pkgs.bash;
  };
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
