{ pkgs, inputs, ... }:
{
  users.groups = {
    ubridge = { };
    wireshark = { };
  };
  users.users."ashenye".extraGroups = [
    "ubridge"
    "wireshark"
  ];
  environment.systemPackages = with pkgs; [
    (gns3-server.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
    })
    (gns3-gui.overrideAttrs {
      doCheck = false;
      doInstallCheck = false;
    })
    qemu
    wireshark
    dynamips
    vpcs
    ubridge
    inetutils
  ];
  security.wrappers.ubridge = {
    source = "/run/current-system/sw/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    capabilities = "cap_net_raw,cap_net_admin+eip";
    owner = "root";
    group = "wireshark";
    permissions = "u+rx,g+x";
  };
}
