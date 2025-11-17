{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/development/shell"
    "${hmProfiles}/features/development/neovim"
  ];
}
