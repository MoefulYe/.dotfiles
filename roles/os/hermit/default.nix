{ paths, ... }:
# 孤独的小寄居蟹nix-darwin, 寄生在macOS上
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/common/base-system/services/openssh.nix"
    "${osProfiles}/common/nix-settings/nix.nix"
    "${osProfiles}/preferences/standard"
    "${osProfiles}/utils/standard"
    "${osProfiles}/nix/garbage-collector.nix"
    "${osProfiles}/nix/nix-index.nix"
  ];
}
