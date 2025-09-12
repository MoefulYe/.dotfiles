{ paths, ... }:
let
  inherit (paths) hmProfiles;
in
{
  imports = [
    "${hmProfiles}/quirks/github-access-limits.nix"
    "${hmProfiles}/perferences"
    "${hmProfiles}/features/desktop"
    "${hmProfiles}/features/browsers/zen"
    "${hmProfiles}/features/communicating/cn.nix"
    "${hmProfiles}/development/code.nix"
    "${hmProfiles}/development/cursor.nix"
    "${hmProfiles}/development/git.nix"
    "${hmProfiles}/development/kitty.nix"
    "${hmProfiles}/development/ssh.nix"
    "${hmProfiles}/development/shell"
    "${hmProfiles}/development/neovim"
    "${hmProfiles}/downloading/bittorrent.nix"
    "${hmProfiles}/editors/gimp.nix"
    "${hmProfiles}/knowledge/obsidian.nix"
    "${hmProfiles}/knowledge/xournalpp.nix"
    "${hmProfiles}/knowledge/zotero.nix"
    "${hmProfiles}/office/wps.nix"
    "${hmProfiles}/streaming/obs.nix"
    "${hmProfiles}/streaming/moonlight.nix"
    "${hmProfiles}/viewers/mpv"
    "${hmProfiles}/viewers/imv.nix"
    "${hmProfiles}/viewers/zathura.nix"
  ];
}
