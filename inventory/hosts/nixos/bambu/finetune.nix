{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "25.11";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  boot.kernel.sysctl = {
    # Keep Linux bridge traffic out of netfilter; Docker bridge traffic is not using
    # the transparent-proxy path on this host.
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;

    # Improve queueing and congestion control for Mihomo's own outbound TCP flows.
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # With 8 GiB RAM we can afford larger TCP buffers for Mihomo and other local
    # outbound sockets, which helps long-fat paths and many concurrent flows.
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 262144 16777216";
    "net.ipv4.tcp_wmem" = "4096 262144 16777216";

    # Give the networking stack a deeper ingress queue before packets are dropped.
    "net.core.netdev_max_backlog" = 16384;

    # Raise conntrack capacity for NAT + TProxy workloads.
    "net.netfilter.nf_conntrack_max" = 524288;

    # Larger neighbor caches help when this host fronts more LAN peers / containers / VMs.
    "net.ipv4.neigh.default.gc_thresh1" = 2048;
    "net.ipv4.neigh.default.gc_thresh2" = 4096;
    "net.ipv4.neigh.default.gc_thresh3" = 8192;
  };

  boot.kernelModules = [
    "tcp_bbr"
    "nf_conntrack"
    "nf_conntrack_netlink"
  ];

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.ports = [ 22 ];
  infra.dnsctl = {
    ipv4 = "10.87.5.91";
    extraRecords = [
      {
        name = "reed.zjucst";
        type = "A";
        values = [ "192.168.231.1" ];
      }
    ];
  };
}
