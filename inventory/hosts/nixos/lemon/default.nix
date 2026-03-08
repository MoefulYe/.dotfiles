{ paths, ... }:
let
  inherit (paths) infra;
in
{
  imports = [
    "${infra}/remote-deploy/deployee.nix"
    ./hardware-configuration.nix
    ./fine-tuning.nix
    ./networking.nix
    ./users.nix
    ./services
  ];
}
