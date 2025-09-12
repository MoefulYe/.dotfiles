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
    "${osProfiles}/hardware/gaomon.nix"
    "${osProfiles}/nix/nix-index.nix"
    "${osProfiles}/quirks/fix-fcitx5-svg-show-nothing.nix"
    "${osProfiles}/quirks/fix-fn-keys.nix"
    "${osProfiles}/quirks/unsafe-libxml2-2.13.8.nix"
    "${osProfiles}/quirks/unsafe-openssl.nix"
  ];
}
