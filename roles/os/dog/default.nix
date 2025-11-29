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
  ];
}
