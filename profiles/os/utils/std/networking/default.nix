{
  pkgs,
  ...
}:
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
