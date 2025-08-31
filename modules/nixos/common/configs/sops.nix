{
  sops = {
    defaultSopsFile = ../../../../secrets/default.yaml;
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
