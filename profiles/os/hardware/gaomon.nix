{
  config,
  ...
}:
{
  hardware.opentabletdriver = {
    enable = false;
  };
  services.xserver.digimend.enable = true;
  boot.extraModulePackages = [
    config.boot.kernelPackages.digimend
  ];
}
