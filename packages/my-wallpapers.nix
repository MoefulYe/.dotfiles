{
  fetchzip,
  stdenv,
  url,
  hash,
}:
stdenv.mkDerivation {
  pname = "my-wallpapers";
  version = "2025-08-11";
  src = fetchzip {
    inherit url hash;
  };
  installPhase = ''
    mkdir -p $out/
    cp -r $src/* $out/
  '';
}
