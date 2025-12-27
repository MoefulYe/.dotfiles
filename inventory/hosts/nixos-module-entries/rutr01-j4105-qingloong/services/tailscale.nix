{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--advertise-routes=192.168.231.0/24"
    "--accept-dns=false"
    "--advertise-exit-node"
  ];
  services.tailscale.useRoutingFeatures = "server";
  networking.firewall = {
    allowedUDPPorts = [ 41641 ]; # 允许直连端口
    trustedInterfaces = [ "tailscale0" ];
  };
}
