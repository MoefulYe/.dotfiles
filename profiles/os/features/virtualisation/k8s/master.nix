{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    kubernetes-helm
    cilium-cli
  ];

  services.kubernetes =
    let
      cluster = import ./cluster.nix { inherit pkgs; };
      inherit (cluster)
        kubeMasterIP
        kubeMasterHostname
        kubeMasterAPIServerPort
        corednsFile
        apiServerEndpoint
        ;
    in
    {
      roles = [
        "master"
      ];
      masterAddress = kubeMasterHostname;
      apiserverAddress = apiServerEndpoint;
      easyCerts = true;
      apiserver = {
        securePort = kubeMasterAPIServerPort;
        advertiseAddress = kubeMasterIP;
        allowPrivileged = true;
      };
      # use coredns
      addons.dns.enable = true;
      # needed if you use swap
      kubelet.extraOpts = "--fail-swap-on=false --resolv-conf=${corednsFile} --pod-infra-container-image=registry.k8s.io/pause:3.9"; # 解决集群内 DNS 解析失败的问题，见 issues.txt
    };
}
