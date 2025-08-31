{ pkgs, ... }@inputs:
{
  # shortcuts
  # appearance
  programs.zen-browser.profiles.default-profile = {
    search = import ./search.nix inputs;
    extensions = import ./extensions.nix inputs;
    settings = import ./settings.nix inputs;
  };
  home.file.".zen/default-profile/zen-keyboard-shortcuts.json".source = ./shortcuts.json;
}
