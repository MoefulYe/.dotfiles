{
  paths,
  pkgs,
  userInfo,
  inputs,
  ...
}:
let
  inherit (paths) sharedProfiles;
in
{
  imports = [
    "${sharedProfiles}/nix-settings/nixpkgs.nix"
    inputs.nur.modules.homeManager.default
  ];
  home.stateVersion = import "${sharedProfiles}/nix-settings/state-version.nix";
  home.packages = with pkgs; [
    home-manager
  ];
  home.username = userInfo.username;
  # TODO 不定义这个选项会有影响吗
  home.homeDirectory = "/home/${userInfo.username}";
}
