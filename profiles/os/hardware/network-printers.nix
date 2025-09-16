{ pkgs, ... }:
{
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.hplip
  ];
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };
}
