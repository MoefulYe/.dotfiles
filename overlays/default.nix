#
# This file defines overlays/custom modifications to upstream packages
#
{ inputs, outputs, ... }:
let
  electronArgs = [
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
  ];
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    vscode = prev.vscode.override {
      commandLineArgs = electronArgs;
    };
    obsidian = prev.obsidian.override {
      commandLineArgs = electronArgs;
    };
    qq = prev.qq.override {
      commandLineArgs = electronArgs;
    };
    code-cursor = prev.code-cursor.override {
      commandLineArgs = (builtins.concatStringsSep " " electronArgs);
    };
    keyd = prev.keyd.overrideAttrs (old: {
      version = "custom";
      src = prev.fetchFromGitHub {
        owner = "rvaiya";
        repo = "keyd";
        rev = "19135668c20d3fa8c2a906d09e78c94003aae1cd";
        hash = "sha256-ljp58wsKm2Ebb2mK9xf71nlrbckEkqMQHzVakQStFiM=";
      };
    });
  };
  add-my-pkgs = final: prev: {
    my-pkgs = outputs.packages."${final.system}";
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
