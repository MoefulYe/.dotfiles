{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    tcpdump
    iproute2
    dig
    nmap
    mtr
    iperf3
    ethtool
  ];
}
