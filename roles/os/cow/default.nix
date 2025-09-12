{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/utils/minimal"
  ];
}
