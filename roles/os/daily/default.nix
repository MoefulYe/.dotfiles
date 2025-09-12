{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/desktop"
    "${osProfiles}/features/development/gns3.nix"
    "${osProfiles}/features/development/wireshark.nix"
    "${osProfiles}/features/virtualisation/podman.nix"
    "${osProfiles}/hardware/gaomon.nix"
    "${osProfiles}/nix/nix-index.nix"
  ];
}
