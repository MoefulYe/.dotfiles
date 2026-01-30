{ pkgs, inputs, ... }:
{
  fonts = pkgs.callPackage ./my-fonts.nix {
    url = "https://blob.desktop.nix.059867.xyz/fonts.zip";
    hash = "sha256-/1ryVz2fcIOftsUjPCuQI5zMmtNJE3g4AUf92Zwux8o=";
  };
  swaylock-background = pkgs.callPackage ./my-swaylock-background.nix {
    url = "https://blob.desktop.nix.059867.xyz/swaylock.jpg";
    hash = "sha256-C5UuZeec+mGerebHffg+g8CNrOZd6OYG0LDnn56ldtE=";
  };
  wallpapers = pkgs.callPackage ./my-wallpapers.nix {
    url = "https://blob.desktop.nix.059867.xyz/wallpapers.zip";
    hash = "sha256-yqsICyzW692/Qa+n/IU6rjpjmgzeG7YP7HxHSuc1mes=";
  };
  zju-connect = pkgs.callPackage ./zju-connect.nix { };
  gnome-terminal = pkgs.callPackage ./gnome-terminal.nix { };
  retro-crt = pkgs.callPackage ./retro-crt.nix { };
  downloader = pkgs.callPackage ./downloader { };
  ensure-exist = pkgs.callPackage ./ensure-exist { };

  # Neovim packages
  nvim = pkgs.callPackage ./nvim { inherit inputs; lite = false; };
  nvim-lite = pkgs.callPackage ./nvim { inherit inputs; lite = true; };
}
