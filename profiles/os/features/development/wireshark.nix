{ pkgs, ... }:
{
  users.groups = {
    wireshark = { };
  };
  environment.systemPackages = with pkgs; [
    wireshark
  ];
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    capabilities = "cap_net_raw,cap_net_admin+eip";
    owner = "root";
    group = "wireshark";
    permissions = "u+rx,g+x";
  };
}
