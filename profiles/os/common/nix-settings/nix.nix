{
  paths,
  pkgs,
  ...
}:
let
  inherit (paths) sharedProfiles;
in
{
  imports = [
    "${sharedProfiles}/nix-settings/nix-conf-settings.nix"
    "${sharedProfiles}/nix-settings/nixpkgs.nix"
  ];
  nix.channel.enable = false;
  nix.settings.trusted-users =
    if pkgs.stdenv.isLinux then
      [
        "root"
        "@wheel"
      ]
    else
      [
        "root"
        "@admin"
      ];
  system.stateVersion =
    if pkgs.stdenv.isLinux then
      import "${sharedProfiles}/nix-settings/state-version.nix"
    else
      import "${sharedProfiles}/nix-settings/darwin-state-version.nix";
}
