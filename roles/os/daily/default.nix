{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common"
    "${osProfiles}/perferences/standard"
    "${osProfiles}/utils/standard"
  ];
}
