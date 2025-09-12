{
  inputs,
  paths,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = "${paths.secrets}/default.yaml";
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
