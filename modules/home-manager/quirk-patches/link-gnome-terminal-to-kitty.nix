{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (stdenv.mkDerivation {
      pname = "link-gnome-terminal-to-kitty";
      version = "2025-08-07";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        ln -s ${kitty}/bin/kitty $out/bin/gnome-terminal
      '';
    })
  ];
}
