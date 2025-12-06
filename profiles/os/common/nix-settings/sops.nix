{
  inputs,
  paths,
  isLinux,
  isDarwin,
  ...
}:
{
  imports =
    if isLinux then
      [
        inputs.sops-nix.nixosModules.sops
      ]
    else if isDarwin then
      [
        inputs.sops-nix.darwinModules.sops
      ]
    else
      throw "sops.nix: Unsupported OS";
  sops = {
    defaultSopsFile = "${paths.secrets}/default.yaml";
    age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/keys.txt";
    };
  };
}
