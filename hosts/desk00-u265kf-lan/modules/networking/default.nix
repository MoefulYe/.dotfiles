{ pkgs, ... }:
{
  imports = [
    ./nftables.nix
    ./vpn.nix
  ];
  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];
  # systemd.network.enable = true;
  networking.useNetworkd = true;
  networking.firewall.enable = false;
  networking.wireless = {
    enable = false;
    userControlled.enable = true;
    networks = {
      "ZJUNB" = { };
    };
  };
}
