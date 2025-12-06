{
  paths,
  pkgs,
  userInfo,
  inputs,
  lib,
  isLinux,
  isDarwin,
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
  home.homeDirectory = lib.mkDefault (
    if isLinux then
      "/home/${userInfo.username}"
    else if isDarwin then
      "/Users/${userInfo.username}"
    else
      throw "profiles/hm/common/default.nix: Unsupported platform"
  );
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
