{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
    ./profiles
  ];
  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisablePocket = true;
      DisableProfileImport = true;
      DisableSetDesktopBackground = true;
      DontCheckDefaultBrowser = true;
      Homepage = {
        URL = "https://inftab.com/";
        StartPage = "homepage";
      };
      NewTabPage = true;
      # OfferToSaveLogins = false;
    };
  };
}
