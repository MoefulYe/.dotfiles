{
  inputs,
  config,
  paths,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    defaultSopsFile = "${paths.secrets}/default.yaml";
    age = {
      generateKey = true;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/key.txt";
    };
  };
}
