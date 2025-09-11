{ pkgs, inputs, ... }:
{
  users.groups = {
    ubridge = { };
  };
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
    dynamips
    vpcs
    ubridge
  ];
  security.wrappers.ubridge = {
    source = "/run/current-system/sw/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };
}
