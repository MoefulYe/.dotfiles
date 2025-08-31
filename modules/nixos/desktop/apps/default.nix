{ pkgs, config, ... }:
{
  imports = [
    #./input-method.nix
  ];
  environment.systemPackages = with pkgs; [
    #CHANGEME
    vscode
    firefox
    gparted
    moonlight-qt
  ];
}
