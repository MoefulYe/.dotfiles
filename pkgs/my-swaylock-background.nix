{
  stdenv,
  fetchurl,
  url,
  hash,
}:
stdenv.mkDerivation {
  pname = "my-swaylock-background";
  version = "2025-08-11";
  src = fetchurl {
    inherit hash url;
  };
  installPhase = ''
    mkdir -p $out
    cp $src $out/swaylock.jpg
  '';
  dontUnpack = true;
}
