{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/preferences/standard"
    "${osProfiles}/utils/standard"
    "${osProfiles}/nix/garbage-collector.nix"
  ];
}
