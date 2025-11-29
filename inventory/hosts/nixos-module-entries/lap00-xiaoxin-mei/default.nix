{
  paths,
  ...
}:
let
  inherit (paths) osRoles osProfiles;
in
{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix
    ./power-management.nix
  ];
}
