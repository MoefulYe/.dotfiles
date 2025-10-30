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
  ];
}
