{
  config,
  ...
}:
{
  hardware.opentabletdriver = {
    enable = false;
  };
  services.xserver = {
    digimend.enable = true;
    inputClassSections = [
    ];
  };
  boot.extraModulePackages = [
    config.boot.kernelPackages.digimend
  ];
  #services.xserver = {
  #  wacom.enable = true;
  #  modules = with pkgs; [
  #    xf86_input_wacom
  #  ];
  #  inputClassSections = [
  #    ''
  #      Identifier "Tablet"
  #      Driver "wacom"
  #      MatchDevicePath "/dev/input/event*"
  #      MatchUSBID "256c:0064"
  #    ''
  #  ];
  #  displayManager.setupCommands = '''';
  #};
  #environment.systemPackages = with pkgs; [
  #  libwacom
  #];
}
