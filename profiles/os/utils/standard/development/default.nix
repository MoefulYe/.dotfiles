{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    just
  ];
}
