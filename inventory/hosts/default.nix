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
    nixosConfig = {
      main = ./nixos-module-entries/lap00-xiaoxin-mei;
      extra = desktopQuirks ++ [ ];
    };
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
    darwinConfig = {
      main = ./darwin-module-entries/lap01-macm4-mume;
      extra = [ ];
    };
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
  rutr01-n1-qingloong = {
    system = "aarch64-linux";
    aliases = [
      "rutr01"
      "qingloong"
    ];
    role = "router-backup";
    tags = [
      "void"
      "router"
      # "nixos"
    ];
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
}
