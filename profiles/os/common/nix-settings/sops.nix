{
  pkgs,
  inputs,
  paths,
  ...
}:
{
  sops = {
    defaultSopsFile = "${paths.secrets}/default.yaml";
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}

