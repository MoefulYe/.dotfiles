{ lib, lite, ... }:
{
  # Import all config modules
  imports = [
    ./options.nix
    ./keymaps.nix
    ./autocommands.nix
    ./plugins
  ];

  # Performance
  performance = {
    byteCompileLua.enable = true;
  };

  # Aliases
  viAlias = true;
  vimAlias = true;
}
