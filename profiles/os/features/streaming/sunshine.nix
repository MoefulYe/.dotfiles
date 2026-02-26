{ pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    # FIXME
    package = pkgs.pkgs-stable.sunshine;
  };
  networking.firewall = {
    allowedTCPPorts = [
      47984
      47989
      47990
      48010
    ];
    allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48000;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };
}
