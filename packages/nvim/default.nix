{
  pkgs,
  lib,
  inputs,
  lite ? true,
}:
let
  nixvim = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  nvimConfig = {
    inherit pkgs;
    module = {
      disabledModules = [
        "${inputs.nixvim}/modules/top-level/files"
      ];
      imports = [
        (import ./config { inherit lib lite; })
        ./nixvim-files-default.nix
      ];
    };
    extraSpecialArgs = { inherit lite; };
  };
in
nixvim.makeNixvimWithModule nvimConfig
