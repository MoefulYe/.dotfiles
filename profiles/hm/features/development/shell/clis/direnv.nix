{ config, lib, ... }:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };
  programs.zsh.initContent = ''
    [ -z "''${DISABLE_DIRENV-}" ] && eval "$(${lib.getExe config.programs.direnv.package} hook zsh)"
  '';
}
