{
  isLinux,
  pkgs,
  ...
}:
{
  users =
    if isLinux then
      {
        defaultUserShell = pkgs.bash;
      }
    else
      { };
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
