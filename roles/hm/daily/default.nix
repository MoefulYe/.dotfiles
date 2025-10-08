{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/preferences"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/desktop"
    "${hmProfiles}/features/browsers/zen"
    "${hmProfiles}/features/communicating/cn.nix"
    "${hmProfiles}/features/development/code.nix"
    "${hmProfiles}/features/development/cursor.nix"
    "${hmProfiles}/features/development/git.nix"
    "${hmProfiles}/features/development/kitty.nix"
    "${hmProfiles}/features/development/ssh.nix"
    "${hmProfiles}/features/development/shell"
    "${hmProfiles}/features/development/neovim"
    "${hmProfiles}/features/downloading/bittorrent.nix"
    "${hmProfiles}/features/editors/gimp.nix"
    "${hmProfiles}/features/knowledge/obsidian.nix"
    "${hmProfiles}/features/knowledge/xournalpp.nix"
    "${hmProfiles}/features/knowledge/zotero.nix"
    "${hmProfiles}/features/office/wps.nix"
    "${hmProfiles}/features/streaming/obs.nix"
    "${hmProfiles}/features/streaming/moonlight.nix"
    "${hmProfiles}/features/viewers/mpv"
    "${hmProfiles}/features/viewers/imv.nix"
    "${hmProfiles}/features/viewers/zathura.nix"
    "${hmProfiles}/features/llms/codex.nix"
    "${hmProfiles}/features/llms/gemini"
    "${hmProfiles}/features/llms/cherry-studio.nix"
  ];
}
