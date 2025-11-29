{ paths, inventory, ... }:
let
  inherit (paths) hmProfiles hmQuirks;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/development/aws.nix"
    "${hmProfiles}/features/development/git.nix"
    "${hmProfiles}/features/development/ssh/github.nix"
    "${hmProfiles}/features/development/shell"
    "${hmProfiles}/features/topology/ssh.nix"
  ];
}
