{ paths, ... }:
let
  inherit (paths) infra;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./users.nix
    ./networking.nix
    ./fine-tuning.nix
    ./services
    ./mircovm.nix
    "${infra}/remote-builder/client.nix"
    "${infra}/remote-deploy/deployee.nix"
  ];
}
