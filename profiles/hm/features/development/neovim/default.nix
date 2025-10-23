{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    # ./settings.nix
    # ./autocmds.nix
    # ./keymaps.nix
    # ./plugins
  ];
  programs.nixvim.enable = true;
}
