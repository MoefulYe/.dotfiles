{ paths, ... }:
let
  inherit (paths) infra;
in
{
  imports = [
    ./keyboard.nix
    ./users.nix
    ./home-manager.nix
    "${infra}/remote-deploy/deployee.nix"
  ];
}
