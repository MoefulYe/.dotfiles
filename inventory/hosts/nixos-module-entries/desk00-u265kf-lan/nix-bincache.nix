{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/lib/nix-binary-cache/cache-priv-key.pem";
  };
}
