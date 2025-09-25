{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
  programs.zsh.shellInit = ''
    set -o emacs 
  '';
}
