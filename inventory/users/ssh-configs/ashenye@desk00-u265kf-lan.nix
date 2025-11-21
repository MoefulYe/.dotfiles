{ pkgs, ... }:
let
  conf = pkgs.writeText "ashenye@desk00.conf" ''
    Host desk00
      HostName 10.87.5.23
      User ashenye
      Port 2222
  '';
in
{
  programs.ssh.includes = [
    "${conf}"
  ];
}
