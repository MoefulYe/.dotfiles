{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks sharedProfiles;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/development/shell"
    "${hmProfiles}/features/development/neovim"
    "${sharedProfiles}/nix-settings/nix-conf-settings.nix"
  ];
}
