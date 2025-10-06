{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.bash;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
