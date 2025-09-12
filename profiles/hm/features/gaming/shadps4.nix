{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    shadps4
  ];
}
