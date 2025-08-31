{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    inetutils
    tcpdump
    iproute2
    dig
    curl
    nmap
  ];
}
