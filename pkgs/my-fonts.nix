{
  fetchzip,
  stdenv,
  url,
  hash,
}:
stdenv.mkDerivation {
  pname = "my-fonts";
  version = "2025-08-11";
  src = fetchzip {
    inherit hash url;
  };
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -r $src/* $out/share/fonts/
  '';
}
