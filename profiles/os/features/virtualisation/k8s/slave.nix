{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    kubernetes-helm
    cilium-cli
  ];
}
