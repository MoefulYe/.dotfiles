let
  mkQuirksEntry = modulename: ../../../quirks/os + "/" + modulename;
  desktopQuirks = [
    (mkQuirksEntry "fix-fn-keys.nix")
    (mkQuirksEntry "fix-fcitx5-svg-show-nothing.nix")
  ];
in
{
  desk00-u265kf-lan = {
    system = "x86_64-linux";
    role = "cat";
    tags = [ ];
    description = "daily used desktop";
    priUser = "ashenye";
    nixosConfig = {
      main = ./nixos-module-entries/desk00-u265kf-lan;
      extra = desktopQuirks ++ [ ];
    };
  };
  lap00-xiaoxin-mei = {
    system = "x86_64-linux";
    role = "cat";
    tags = [ ];
    description = "daily used laptop";
    priUser = "ashenye";
    nixosConfig = {
      main = ./nixos-module-entries/lap00-xiaoxin-mei;
      extra = desktopQuirks ++ [ ];
    };
  };
}
