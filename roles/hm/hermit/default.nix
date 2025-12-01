{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/preferences"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/browsers/zen"
    "${hmProfiles}/features/daily-scripts"
    "${hmProfiles}/features/cool"
    "${hmProfiles}/features/development/code.nix"
    "${hmProfiles}/features/development/aws.nix"
    "${hmProfiles}/features/development/git.nix"
    "${hmProfiles}/features/development/kitty.nix"
    "${hmProfiles}/features/development/ssh"
    "${hmProfiles}/features/development/shell"
    "${hmProfiles}/features/development/neovim"
    "${hmProfiles}/features/development/nix"
    "${hmProfiles}/features/knowledge/obsidian.nix"
    "${hmProfiles}/features/knowledge/xournalpp.nix"
    "${hmProfiles}/features/knowledge/zotero.nix"
    "${hmProfiles}/features/viewers/mpv"
    "${hmProfiles}/features/llms/codex.nix"
    "${hmProfiles}/features/llms/gemini"
    "${hmProfiles}/features/integration/kdeconnect"
    "${hmProfiles}/features/remote-desktop/vnc.nix"
    "${hmProfiles}/features/topology/ssh.nix"
  ];
}
