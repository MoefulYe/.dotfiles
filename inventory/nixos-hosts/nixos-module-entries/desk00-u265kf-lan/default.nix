{ paths, pkgs, ... }:
let
  inherit (paths) osProfiles osRoles;
  kubeMasterIP = "127.0.0.1";
  kubeMasterHostname = "localhost";
  kubeMasterAPIServerPort = 6443;
in
{
  imports = [
    "${osRoles}/cat"
    "${osRoles}/daily"
    "${osProfiles}/hardware/nvidia-daily.nix"
    "${osProfiles}/features/streaming/sunshine.nix"
    "${osProfiles}/features/gaming/steam.nix"
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./bootloader.nix
    ./users
  ];
  services.openssh.settings.PasswordAuthentication = true;

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}
