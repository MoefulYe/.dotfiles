{ ... }:
{
  # ------------------------------------------------------------
  # Networking template
  # Choose ONE of the following options.
  # ------------------------------------------------------------

  # Option A: simple DHCP (let NixOS pick backend)
  # networking.useDHCP = true;

  # Option B: systemd-networkd with DHCP on a specific interface
  # services.resolved.enable = true;
  # networking.useNetworkd = true;
  # systemd.network.enable = true;
  # systemd.network.networks."40-<iface>" = {
  #   matchConfig.Name = "<iface>";
  #   networkConfig = {
  #     DHCP = "ipv4"; # or "yes" for ipv4+ipv6
  #   };
  # };

  # Option C: systemd-networkd with static IPv4
  # services.resolved.enable = true;
  # networking.useNetworkd = true;
  # systemd.network.enable = true;
  # systemd.network.networks."40-<iface>" = {
  #   matchConfig.Name = "<iface>";
  #   networkConfig = {
  #     Address = [ "<ip>/<prefix>" ];
  #     Gateway = [ "<gateway>" ];
  #     DNS = [ "1.1.1.1" "8.8.8.8" ];
  #   };
  # };
}

# Option D: systemd-networkd with static IPv4 + IPv6
# services.resolved.enable = true;
# networking.useNetworkd = true;
# systemd.network.enable = true;
# systemd.network.networks."40-<iface>" = {
#   matchConfig.Name = "<iface>";
#   networkConfig = {
#     Address = [
#       "<ipv4>/<prefix>"
#       "<ipv6>/<prefix>"
#     ];
#     Gateway = [
#       "<ipv4-gateway>"
#     ];
#     Gateway6 = [
#       "<ipv6-gateway>"
#     ];
#     DNS = [ "1.1.1.1" "8.8.8.8" ];
#   };
# };
