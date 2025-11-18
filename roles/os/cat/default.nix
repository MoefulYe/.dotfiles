{ paths, ... }:
let
  inherit (paths) osProfiles hmProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/preferences/standard"
    "${osProfiles}/utils/standard"
    "${osProfiles}/nix/garbage-collector.nix"
    "${hmProfiles}/features/integration/kdeconnect/expose-ports.nix"
    "${osProfiles}/desktop"
    # "${osProfiles}/features/development/gns3.nix"
    "${osProfiles}/features/development/wireshark.nix"
    "${osProfiles}/features/virtualisation/podman.nix"
    "${osProfiles}/hardware/gaomon.nix"
    "${osProfiles}/hardware/network-printers.nix"
    "${osProfiles}/nix/nix-index.nix"
  ];
}
