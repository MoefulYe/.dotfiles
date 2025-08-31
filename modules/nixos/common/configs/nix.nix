{
  config,
  inputs,
  outputs,
  ...
}:
let
  inherit (config.systemProfiles.features) enableAutoGC;
  inherit (config.systemProfiles.basic.host) stateVersion;
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    overlays = (builtins.attrValues outputs.overlays);
  };
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
    extraOptions = ''
      warn-dirty = false
    '';
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        # "https://mirrors.cernet.edu.cn/nix-channels/store"
        # "https://mirror.nju.edu.cn/nix-channels/store"
        # "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        "ashenye" # TODO improve it
      ];
    };
    gc = {
      automatic = enableAutoGC;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = stateVersion;
}
