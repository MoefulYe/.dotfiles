{ pkgs, ... }:
{
  imports = [
    ./yazi.nix
    ./direnv.nix
    ./zoxide.nix
  ];
  home.packages = with pkgs; [
    yazi
    fzf
    cloc
    lazygit
    devenv
    lsd
  ];
}
