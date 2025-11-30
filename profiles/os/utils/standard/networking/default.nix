{
  pkgs,
  lib,
  isLinux,
  ...
}:
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
    ++ (lib.optionals isLinux [
      iproute2
      ethtool
    ]);
}
