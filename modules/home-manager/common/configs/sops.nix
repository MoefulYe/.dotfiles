{ inputs, config, rootPath, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = "${rootPath}/secrets/default.yaml";
    age = {
      generateKey = true;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/key.txt";
    };
  };
}
