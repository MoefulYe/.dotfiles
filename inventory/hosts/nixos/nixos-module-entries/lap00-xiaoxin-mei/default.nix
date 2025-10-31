{
  paths,
  ...
}:
let
  inherit (paths) osRoles osProfiles;
in
{
  imports = [
    "${osRoles}/cat"
    "${osRoles}/daily"
    "${osProfiles}/hardware/wireless.nix"
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix
  ];
}
