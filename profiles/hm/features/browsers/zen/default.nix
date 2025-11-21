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
  home.sessionVariables = {
    # FIXME just work around for rdd hardware acceleration issue, fix it later
    # MOZ_DISABLE_RDD_SANDBOX = "1";
  };
}
