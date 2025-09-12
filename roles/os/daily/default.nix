{ paths, ... }:
let
  inherit (paths) osProfiles;
in
{
  imports = [
    "${osProfiles}/desktop"
    "${osProfiles}/features/development/gns3.nix"
    "${osProfiles}/features/development/wireshark.nix"
    "${osProfiles}/features/virtualisation/podman.nix"
    "${osProfiles}/features/hardware/gaomon.nix"
    "${osProfiles}/features/nix/nix-index.nix"
    "${osProfiles}/features/quirks/fix-fcitx5-svg-show-nothing.nix"
    "${osProfiles}/features/quirks/fix-fn-keys.nix"
    "${osProfiles}/features/quirks/unsafe-libxml2-2"
    "${osProfiles}/features/quirks/unsafe-openssl-1.1.1w.nix"
    "${osProfiles}/features/quirks/unsafe-openssl-dingtalk.nix"
  ];
}
