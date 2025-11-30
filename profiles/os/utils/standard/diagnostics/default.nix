{
  pkgs,
  lib,
  isLinux,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [ ]
    ++ (lib.optionals isLinux [
      strace
      ltrace
      perf
      sysstat
    ]);
}
