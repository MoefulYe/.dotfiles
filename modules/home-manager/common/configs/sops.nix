{
  inputs,
  config,
  secretsPath,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = "${secretsPath}/secrets/default.yaml";
    age = {
      generateKey = true;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/key.txt";
    };
  };
}
