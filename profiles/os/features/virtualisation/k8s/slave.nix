{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];
  services.kubernetes =
    let
      cluster = import ./cluster.nix { inherit pkgs; };
      inherit (cluster)
        kubeMasterHostname
        corednsFile
        apiServerEndpoint
        ;
    in
    {
      roles = [ "node" ]; # 角色为 "node"
      masterAddress = kubeMasterHostname;
      easyCerts = true; # 与主节点保持一致
      kubelet.kubeconfig.server = apiServerEndpoint;
      apiserverAddress = apiServerEndpoint;
      # use coredns
      addons.dns.enable = true;
      # needed if you use swap
      kubelet.extraOpts = "--fail-swap-on=false --resolv-conf=${corednsFile} --pod-infra-container-image=registry.k8s.io/pause:3.9";
    };
  networking.firewall.enable = false;
}
