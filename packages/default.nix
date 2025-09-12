{ pkgs, ... }:
{
  fonts = pkgs.callPackage ./my-fonts.nix {
    url = "https://pub-074e0c0a63da4754aa4f0abb1851b769.r2.dev/fonts.zip";
    hash = "sha256-/1ryVz2fcIOftsUjPCuQI5zMmtNJE3g4AUf92Zwux8o=";
  };
  swaylock-background = pkgs.callPackage ./my-swaylock-background.nix {
    url = "https://pub-074e0c0a63da4754aa4f0abb1851b769.r2.dev/swaylock.jpg";
    hash = "sha256-C5UuZeec+mGerebHffg+g8CNrOZd6OYG0LDnn56ldtE=";
  };
  wallpapers = pkgs.callPackage ./my-wallpapers.nix {
    url = "https://pub-074e0c0a63da4754aa4f0abb1851b769.r2.dev/wallpapers.zip";
    hash = "sha256-3hS/mgfKweSP66JycLoxsa5I9Iojrn5gZWFAlFXnWfo=";
  };
  zju-connect = pkgs.callPackage ./zju-connect.nix { };
  gnome-terminal = pkgs.callPackage ./gnome-terminal.nix { };
  retro-crt = pkgs.callPackage ./retro-crt.nix { };
}
