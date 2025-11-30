{ pkgs, lib, ... }:
{
  environment.systemPackages =
    with pkgs;
    [ ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      strace
      ltrace
      perf
      sysstat
    ]);
}
