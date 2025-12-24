{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks sharedProfiles;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/development/git"
    "${hmProfiles}/features/development/ssh"
    "${hmProfiles}/features/topology/ssh.nix"
  ];
}
