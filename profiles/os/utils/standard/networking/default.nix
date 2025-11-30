{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      wget
      curl
      tcpdump
      dig
      nmap
      mtr
      iperf3
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      iproute2
      ethtool
    ]);
}
