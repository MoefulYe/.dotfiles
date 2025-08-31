{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.systemProfiles.basic.i18n) locale timezone;
in
{
  time.timeZone = timezone;
  i18n.defaultLocale = locale;
}
