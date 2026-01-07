{ pkgs, ... }:
rec {
  kubeMasterIP = "192.168.231.65";
  kubeMasterHostname = "vm01-lap00-red.void";
  kubeMasterAPIServerPort = 6443;
  corednsFile = pkgs.writeText "resolv.conf" ''
    nameserver 1.1.1.1
  '';
  apiServerEndpoint = "https://${kubeMasterIP}:${toString kubeMasterAPIServerPort}";
}
