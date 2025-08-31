{ inputs, config, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = ../../../../secrets/default.yaml;
    age = {
      generateKey = true;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/key.txt";
    };
  };
}
