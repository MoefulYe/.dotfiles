{ config, lib, ... }:
{
  systemd.nspawn."ubuntu-ml" = {
    networkConfig = {
      MACVLAN = "enp131s0:eth0";
    };
    execConfig = {
      Boot = true;
      Environment = [
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
        "PATH=/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
      Hostname = "ubuntu-ml";
      ResolvConf = "bind-host";
    };
    filesConfig = {
      Bind = [
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-modeset"
        "/dev/nvidia-uvm"
        "/dev/nvidia-uvm-tools"
        "/dev/dri"
      ];
      BindReadOnly = [
        "/run/current-system/sw"
        "/run/opengl-driver"
        "/run/opengl-driver-32"
        "/nix"
      ];
    };
  };

  systemd.services."systemd-nspawn@ubuntu-ml" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      DevicePolicy = "closed";
      DeviceAllow = [
        "/dev/nvidia0 rw"
        "/dev/nvidiactl rw"
        "/dev/nvidia-modeset rw"
        "/dev/nvidia-uvm rw"
        "/dev/nvidia-uvm-tools rw"
        "/dev/dri/card1 rw"
        "/dev/dri/renderD128 rw"
      ];
    };
    wantedBy = [ "multi-user.target" ];
  };
}
