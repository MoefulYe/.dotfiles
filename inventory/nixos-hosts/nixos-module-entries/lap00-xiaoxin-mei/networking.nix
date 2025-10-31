{ config, paths, ... }:
let
  inherit (paths) osProfiles;
  outbounds = [
    "wlp2s0"
  ];
in
{
  imports = [
    "${osProfiles}/features/networking/tproxy"
    "${osProfiles}/hardware/wireless.nix"
  ];
  osProfiles.features.tproxy = {
    nftables = {
      inherit outbounds;
    };
    smartdns = {
      enableAntiAD = true;
    };
  };
  networking.interfaces.wlp2s0.useDHCP = true;
}
