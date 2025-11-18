{
  desk00-u265kf-lan = {
    mainModule = ./nixos-module-entries/desk00-u265kf-lan;
    extraModules = [
      ../../../quirks/os/fix-fn-keys.nix
      ../../../quirks/os/fix-fcitx5-svg-show-nothing.nix
    ];
    hostInfo = {
      system = "x86_64-linux";
      role = "cat";
      tags = [];
      description = "daily used desktop";
      priUser = "ashenye";
    };
  };
  lap00-xiaoxin-mei = {
    mainModule = ./nixos-module-entries/lap00-xiaoxin-mei;
    extraModules = [
      ../../../quirks/os/fix-fn-keys.nix
      ../../../quirks/os/fix-fcitx5-svg-show-nothing.nix
    ];
    hostInfo = {
      system = "x86_64-linux";
      role = "cat";
      tags = [];
      description = "daily used laptop";
      priUser = "ashenye";
    };
  };
}
