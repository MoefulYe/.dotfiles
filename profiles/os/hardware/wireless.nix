{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];
  networking.useDHCP = lib.mkDefault true;
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      "ZJUNB" = { };
    };
  };
}
