{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    btop
    neofetch
    wget
    curl
    git
    fd
    ripgrep
    tree
    file
    unzip
    zip
    rsync
    just
    fzf
    sops
  ];
}
