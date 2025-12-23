{ paths, lib, ... }:
let
  inherit (paths) infra;
in
{
  imports = [
    "${infra}/remote-builder/client.nix"
    "${infra}/remote-deploy/deployee.nix"
    ./bootloader.nix
    ./fine-tuning.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./users.nix
  ];
  services.openssh.permitRootLogin = lib.mkForce "yes";
  services.openssh.passwordAuthentication = lib.mkForce true;
}
