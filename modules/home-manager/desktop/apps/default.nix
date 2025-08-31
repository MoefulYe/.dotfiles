{ pkgs, ... }:
{
  imports = [
    ./file-roller.nix
    ./nautilus.nix
    ./mpv
    ./cn.nix
    ./imv.nix
    ./zathura.nix
    ./zen
    ./neovim
    ./obisidian.nix
    ./learning
    ./shell
    ./dev
  ];
  home.packages = with pkgs; [
    wl-clipboard
    lazygit
    xournalpp
    gimp3
    qbittorrent
    zotero
    devenv
    code-cursor
    obs-studio
  ];
}
