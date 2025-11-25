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
    "${sharedProfiles}/nix-settings/nix-conf-settings.nix"
    "${sharedProfiles}/nix-settings/nixpkgs.nix"
  ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    inherit overlays;
  };
  nix.channel.enable = false;
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  system.stateVersion = import "${sharedProfiles}/nix-settings/state-version.nix";
}
