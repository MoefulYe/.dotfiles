{
  pkgs,
  lib,
  inputs,
  lite ? true,
}:
let
  nixvim = inputs.nixvim.legacyPackages.${pkgs.system};

  nvimConfig = {
    inherit pkgs;
    module = import ./config { inherit lib lite; };
    extraSpecialArgs = { inherit lite; };
  };
in
nixvim.makeNixvimWithModule nvimConfig
