{
  desk00-u265kf-lan = {
    mainModule = ./nixos-module-entries/desk00-u265kf-lan;
    extraModules = [
      ../../quirks/os/fix-fn-keys.nix
      ../../quirks/os/unsafe-openssl.nix
      ../../quirks/os/unsafe-libxml2-2.13.8.nix
      ../../quirks/os/fix-fcitx5-svg-show-nothing.nix
    ];
    hostInfo = {
      system = "x86_64-linux";
      tags = [ "daily" ];
      description = "daily used desktop";
    };
  };
  lap00-xiaoxin-mei = {
    mainModule = ./nixos-module-entries/lap00-xiaoxin-mei;
    extraModules = [
      ../../quirks/os/fix-fn-keys.nix
      ../../quirks/os/unsafe-openssl.nix
      ../../quirks/os/unsafe-libxml2-2.13.8.nix
      ../../quirks/os/fix-fcitx5-svg-show-nothing.nix
    ];
    hostInfo = {
      system = "x86_64-linux";
      tags = [ "daily" ];
      description = "daily used laptop";
    };
  };
}
