{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    jq
    yq-go
  ];
}
