{
  fetchzip,
  stdenv,
  url,
  hash,
}:
stdenv.mkDerivation {
  pname = "my-wallpapers";
  version = "2025-11-08";
  src = fetchzip {
    inherit url hash;
  };
  installPhase = ''
    mkdir -p $out/
    cp -r $src/* $out/
  '';
}
