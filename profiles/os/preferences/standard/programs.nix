{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
  };
  programs.bash.shellInit = ''
    set -o emacs 
  '';
}

