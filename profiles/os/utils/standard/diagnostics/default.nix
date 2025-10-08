{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    strace
    ltrace
  ];
}
