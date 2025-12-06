{
  inputs,
  isLinux,
  isDarwin,
  ...
}:
{
  imports =
    if isLinux then
      [
        inputs.nix-index-database.nixosModules.nix-index
      ]
    else if isDarwin then
      [
        inputs.nix-index-database.darwinModules.nix-index
      ]
    else
      throw "nix-index.nix: Unsupported OS";
}
