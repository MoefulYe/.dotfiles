{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
}
