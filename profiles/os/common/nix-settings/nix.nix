{
  outputs,
  paths,
  ...
}:
let
  inherit (paths) sharedProfiles;
  overlays = (builtins.attrValues outputs.overlays);
in
{
  imports = [
    "${sharedProfiles}/common/nix-settings/nix-conf-settings.nix"
    "${sharedProfiles}/common/nix-settings/nixpkgs.nix"
  ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    inherit overlays;
  };
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  system.stateVersion = import "${sharedProfiles}/common/nix-settings/state-version.nix";
}
