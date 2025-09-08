{ secretsPath, ... }:
{
  sops = {
    defaultSopsFile = "${secretsPath}/default.yaml";
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
