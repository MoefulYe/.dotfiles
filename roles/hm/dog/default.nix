{ paths, lib, ... }:
let
  inherit (paths) hmProfiles hmQuirks infra;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/development"
    "${infra}/ssh"
  ];
}
