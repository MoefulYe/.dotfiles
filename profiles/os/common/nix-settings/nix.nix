{
  pkgs,
  config,
  inputs,
  outputs,
  ...
}:
let
  stateVersion = "24.11";
  overlays = (builtins.attrValues self.overlays);
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    inherit overlays;
  };
  nix = {
    # nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
    # extraOptions = ''
    #   warn-dirty = true
    # '';
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  system = {
    inherit stateVersion;
  };
}
