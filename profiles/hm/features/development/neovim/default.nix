{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./settings.nix
    ./autocmds.nix
    ./keymaps.nix
    ./plugins
  ];
  programs.nixvim.enable = false;
  programs.neovim.enable = true;
}
