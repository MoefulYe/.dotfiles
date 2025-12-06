{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks sharedProfiles;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/daily-scripts"
    "${hmProfiles}/features/development/cli"
    "${hmProfiles}/features/development/neovim"
    "${hmProfiles}/features/development/zsh"
    "${sharedProfiles}/nix-settings/nix-conf-settings.nix"
  ];
}
