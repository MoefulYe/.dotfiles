{ pkgs, ... }:
{
  imports = [
    ./yazi.nix
    ./direnv.nix
    ./zoxide.nix
    ./apps.nix
  ];
}
