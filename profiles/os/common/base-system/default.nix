{ lib, ... }:
{
  imports = [
    ./i18n.nix
    ./sysctl.nix
    ./bootloader.nix
  ];

  options.osProfiles.common.priUser =
    with lib;
    mkOption {
      type = types.nullOr types.str;
      default = null;
    };
}
