{ inputs, pkgs, ... }:
{
  imports = [
    inputs.vscode-server.homeModules.default
  ];
  services.vscode-server.enable = true;
  home.packages = with pkgs; [
    my-pkgs.lazydc
  ];
}
