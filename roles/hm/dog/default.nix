{ paths, lib, ... }:
let
  inherit (paths) hmProfiles hmQuirks;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/daily-scripts"
    "${hmProfiles}/features/development/cli"
    "${hmProfiles}/features/development/git"
    "${hmProfiles}/features/development/neovim"
    "${hmProfiles}/features/development/ssh"
    "${hmProfiles}/features/development/zsh"
    "${hmProfiles}/features/topology/ssh.nix"
  ];
}
