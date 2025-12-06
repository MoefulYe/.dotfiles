#
# This file defines overlays/custom modifications to upstream packages
#
{ self, inputs, ... }:
let
  electronArgs = [
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
  ];
in
{
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: ({
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
  });
  add-my-pkgs = final: prev: {
    pkgs-stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        allowBroken = true;
      };
      overlays = [
        (final: prev: {
          qq = prev.qq.override {
            commandLineArgs = electronArgs;
          };
        })
      ];
    };
    pkgs-stable-with-openssl_1_1_w = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };
    };
    my-pkgs = self.packages."${final.stdenv.hostPlatform.system}" // {
      dingtalk = final.pkgs-stable-with-openssl_1_1_w.callPackage ../packages/dingtalk { };
    };
  };
}
