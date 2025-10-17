{
  paths,
  pkgs,
  userInfo,
  ...
}:
let
  inherit (paths) sharedProfiles;
in
{
  imports = [
    "${sharedProfiles}/common/nix-settings/nixpkgs.nix"
  ];
  home.stateVersion = import "${sharedProfiles}/common/nix-settings/state-version.nix";
  home.packages = with pkgs; [
    home-manager
  ];
  home.username = userInfo.username;
  # TODO 不定义这个选项会有影响吗
  # home.homeDirectory = "/home/${username}";
}
