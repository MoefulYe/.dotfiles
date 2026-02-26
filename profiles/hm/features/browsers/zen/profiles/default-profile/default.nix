{ pkgs, ... }@inputs:
{
  # shortcuts
  # appearance
  programs.zen-browser.profiles.default-profile = {
    search = import ./search.nix inputs;
    extensions = import ./extensions.nix inputs;
    settings = import ./settings.nix inputs;
  };
  xdg.configFile."zen/default-profile/zen-keyboard-shortcuts.json".source = ./shortcuts.json;
}
