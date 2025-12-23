{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/preferences/std"
    "${osProfiles}/utils/tiny"
    "${osProfiles}/nix/garbage-collector.nix"
  ];
}
