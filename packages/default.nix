{ pkgs, ... }:
{
  fonts = pkgs.callPackage ./my-fonts.nix {
    url = "https://blob.nix.pipago360.site/fonts.zip";
    hash = "sha256-/1ryVz2fcIOftsUjPCuQI5zMmtNJE3g4AUf92Zwux8o=";
  };
  swaylock-background = pkgs.callPackage ./my-swaylock-background.nix {
    url = "https://blob.nix.pipago360.site/swaylock.jpg";
    hash = "sha256-C5UuZeec+mGerebHffg+g8CNrOZd6OYG0LDnn56ldtE=";
  };
  wallpapers = pkgs.callPackage ./my-wallpapers.nix {
    url = "https://blob.nix.pipago360.site/wallpapers.zip";
    hash = "sha256-3hS/mgfKweSP66JycLoxsa5I9Iojrn5gZWFAlFXnWfo=";
  };
  zju-connect = pkgs.callPackage ./zju-connect.nix { };
}
