let
  mkQuirksEntry = modulename: ../../quirks/os + ("/" + modulename);
  desktopQuirks = [
    (mkQuirksEntry "fix-fn-keys.nix")
    (mkQuirksEntry "fix-fcitx5-svg-show-nothing.nix")
  ];
in
{
  desk00-u265kf-lan = {
    system = "x86_64-linux";
    aliases = [
      "desk00"
      "lan"
    ];
    role = "cat";
    tags = [
      "void"
      "nixos"
    ];
    description = "daily used desktop";
    priUser = "ashenye";
    nixosConfig = {
      main = ./nixos-module-entries/desk00-u265kf-lan;
      extra = desktopQuirks ++ [ ];
    };
  };
  lap00-xiaoxin-mei = {
    system = "x86_64-linux";
    aliases = [
      "lap00"
      "mei"
    ];
    role = "dog";
    tags = [
      "void"
      "nixos"
    ];
    description = "laptop as server";
    nixosConfig = ./nixos-module-entries/lap00-xiaoxin-mei;
  };
  lap01-macm4-mume = {
    system = "aarch64-darwin";
    aliases = [
      "lap01"
      "mume"
    ];
    role = "hermit";
    tags = [
      "void"
      "darwin"
    ];
    description = "personal laptop";
    darwinConfig = ./darwin-module-entries/lap01-macm4-mume;
  };
  rutr00-k2p-zhuque = {
    system = "aarch64-linux";
    aliases = [
      "rutr00"
      "zhuque"
    ];
    role = "router";
    tags = [
      "void"
      "router"
      "openwrt"
    ];
  };
  rutr01-j4105-qingloong = {
    system = "x86_64-linux";
    aliases = [
      "rutr01"
      "qingloong"
    ];
    role = "dog";
    tags = [
      "void"
      "router"
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/rutr01-j4105-qingloong;
  };
  nas00-8100t-xuanwu = {
    system = "x86_64-linux";
    aliases = [
      "nas00"
      "xuanwu"
    ];
    role = "nas";
    tags = [
      "void"
      # "nixos"
    ];
  };
  vm00-lap00-azure = {
    system = "x86_64-linux";
    aliases = [
      "lap00vm00"
      "azure"
    ];
    role = "bee";
    tags = [
      "void"
      "microvm"
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/vm00-lap00-azure.nix;
  };
  vm01-lap00-red = {
    system = "x86_64-linux";
    aliases = [
      "lap00vm01"
      "red"
    ];
    role = "bee";
    tags = [
      "void"
      "microvm"
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/vm01-lap00-red.nix;
  };
  vm02-lap00-white = {
    system = "x86_64-linux";
    aliases = [
      "lap00vm02"
      "white"
    ];
    role = "bee";
    tags = [
      "void"
      "microvm"
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/vm02-lap00-white.nix;
  };
  vm03-lap00-black = {
    system = "x86_64-linux";
    aliases = [
      "lap00vm03"
      "black"
    ];
    role = "bee";
    tags = [
      "void"
      "microvm"
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/vm03-lap00-black.nix;
  };
  vps00-foxhk-citrus = {
    system = "x86_64-linux";
    aliases = [
      "vps00"
      "citrus"
    ];
    role = "dog";
    tags = [
      "nixos"
    ];
    nixosConfig = ./nixos-module-entries/vps00-foxhk-citrus;
  };
}
