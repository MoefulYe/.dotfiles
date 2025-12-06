{
  pkgs,
  lib,
  isLinux,
  ...
}:
let
  apps =
    [
      ./compression
      ./development
      ./diagnostics
      ./file-management
      ./hardware
      ./misc
      ./monitoring
      ./networking
      ./security
      ./terminal
      ./text-processing
    ]
    |> lib.map (path: import path { inherit pkgs; })
    |> lib.concatLists;
  appsLinuxOnly =
    [
      ./diagnostics/linux.nix
      ./networking/linux.nix
    ]
    |> lib.map (path: import path { inherit pkgs; })
    |> lib.concatLists;
in
{
  environment.systemPackages = apps ++ (lib.optionals isLinux appsLinuxOnly);
}
