{ paths, ... }:
{
  lan = {
    role = "cat";
    priUser = "ashenye";
    alias = [
      "desk00"
      "u265kf"
    ];
    nixosConfig = {
      main = ./nixos/lan;
      extra = [
        "${paths.osQuirks}/fix-fn-keys.nix"
        "${paths.osQuirks}/fix-fcitx5-svg-show-nothing.nix"
      ];
    };
  };
  mume = {
    role = "hermit";
    darwinConfig = ./darwin/mume;
  };
  qingloong = {
    role = "dog";
    nixosConfig = ./nixos/qingloong;
  };
  citrus = {
    role = "dog";
    alias = [
      "vps00"
    ];
    nixosConfig = ./nixos/citrus;
  };
  lemon = {
    role = "dog";
    alias = [
      "vps01"
    ];
    nixosConfig = ./nixos/lemon;
  };
  yuzu = {
    role = "dog";
    alias = [
      "vps02"
    ];
    nixosConfig = ./nixos/yuzu;
  };
}
