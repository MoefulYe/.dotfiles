{ pkgs, ... }:
{
  hmProfiles.dev.daily = false;
  hmProfiles.dev.lite = false;
  home.packages = with pkgs; [
    my-pkgs.lazydc
  ];
}
