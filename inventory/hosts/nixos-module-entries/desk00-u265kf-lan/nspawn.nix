{ config, lib, ... }:
{
  virtualisation.systemd-nspawn.enable = true;

  systemd.nspawn."ubuntu-ml" = {
    enable = true;
    execConfig.Boot = true;
    networkConfig.VirtualEthernet = false;

    bind = [
      "/home/ashenye/repo:/repo"
    ];

    bindRW = [
      "/dev/nvidia0"
      "/dev/nvidiactl"
      "/dev/nvidia-modeset"
      "/dev/nvidia-uvm"
      "/dev/nvidia-uvm-tools"
      "/dev/dri"
    ];

    filesConfig = {
      RootDirectory = "/var/lib/machines/ubuntu-ml";
    };
  };

  systemd.services."systemd-nspawn@ubuntu-ml".wantedBy = [ "multi-user.target" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/machines/ubuntu-ml 0755 root root -"
  ];
}
