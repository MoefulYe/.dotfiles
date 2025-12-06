{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/preferences/std"
    "${osProfiles}/utils/std"
    "${osProfiles}/nix/garbage-collector.nix"
  ];
}
