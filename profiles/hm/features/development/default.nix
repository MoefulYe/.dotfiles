{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.hmProfiles.dev;
in
{
  options.hmProfiles.dev = {
    lite = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    daily = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  imports = [
    ./cli
    ./code
    ./git
    ./kitty
    ./neovim
    ./ssh
    ./zsh
    ./dnsctl
  ];
}
