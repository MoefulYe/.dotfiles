{
  paths,
  ...
}:
let
  inherit (paths) osRoles osProfiles;
in
{
  imports = [
    "${osProfiles}/hardware/wireless.nix"
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix
    ./power-management.nix
  ];
}
