{ paths, ... }:
let
  inherit (paths) infra;
in
{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix
    ./fine-tuning.nix
    ./services
    "${infra}/remote-builder/client.nix"
    "${infra}/remote-deploy/deployee.nix"
  ];
}
