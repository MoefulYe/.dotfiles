{ rootPath, ... }: {
  sops = {
    defaultSopsFile = "${rootPath}/secrets/default.yaml";
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
