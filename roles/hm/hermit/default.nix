{ paths, ... }:
let
  inherit (paths) hmProfiles hmQuirks infra;
in
{
  imports = [
    "${hmQuirks}/github-access-limits.nix"
    "${hmProfiles}/common"
    "${hmProfiles}/nix/sops.nix"
    "${hmProfiles}/features/browsers/zen"
    "${hmProfiles}/features/daily-scripts"
    "${hmProfiles}/features/development/cli"
    "${hmProfiles}/features/development/code"
    "${hmProfiles}/features/development/git"
    "${hmProfiles}/features/development/kitty"
    "${hmProfiles}/features/development/neovim"
    "${hmProfiles}/features/development/ssh"
    "${hmProfiles}/features/development/zsh"
    "${hmProfiles}/features/downloading/bittorrent.nix"
    "${hmProfiles}/features/downloading/aria2.nix"
    "${hmProfiles}/features/gaming/minecraft.nix"
    "${hmProfiles}/features/knowledge"
    "${hmProfiles}/features/llms/codex"
    "${hmProfiles}/features/llms/gemini"
    "${hmProfiles}/features/viewers/mpv"
    "${hmProfiles}/features/viewers/zathura.nix"
    "${infra}/ssh"
  ];
  hmProfiles.my-nvim.lite = false;
  hmProfiles.dev.lite = false;
}
