{
  isLinux,
  pkgs,
  ...
}:
{
  users =
    if isLinux then
      {
        defaultUserShell = pkgs.zsh;
      }
    else
      { };
  programs.zsh.enable = true;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
}
