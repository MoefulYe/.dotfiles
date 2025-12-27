{
  config,
  ...
}:
{
  services.xserver.digimend.enable = false;
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  boot.kernelModules = [ "uinput" ];
}
