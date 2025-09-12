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
    ./users
    ./networking.nix
  ];
  # FIXME
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "libxml2-2.13.8"
  ];
}
