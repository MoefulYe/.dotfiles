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
    "${hmProfiles}/features/cool"
    "${hmProfiles}/features/desktop"
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
    "${hmProfiles}/features/editors/gimp.nix"
    "${hmProfiles}/features/gaming/minecraft.nix"
    "${hmProfiles}/features/instant-messengers/discord.nix"
    "${hmProfiles}/features/instant-messengers/telegram.nix"
    "${hmProfiles}/features/instant-messengers/cn.nix"
    "${hmProfiles}/features/integration/kdeconnect"
    "${hmProfiles}/features/knowledge"
    "${hmProfiles}/features/llms/codex"
    "${hmProfiles}/features/llms/gemini"
    "${hmProfiles}/features/networking/mihomo-xdg"
    "${hmProfiles}/features/office/wps.nix"
    "${hmProfiles}/features/remote-desktop/vnc.nix"
    "${hmProfiles}/features/streaming/obs.nix"
    "${hmProfiles}/features/streaming/moonlight.nix"
    "${hmProfiles}/features/topology/ssh.nix"
    "${hmProfiles}/features/viewers/mpv"
    "${hmProfiles}/features/viewers/imv.nix"
    "${hmProfiles}/features/viewers/zathura.nix"
  ];
  hmProfiles.my-nvim.lite = false;
}
