{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    strace
    ltrace
    perf
    sysstat
  ];
}
