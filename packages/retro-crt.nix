{ stdenv, fetchFromGitHub, ... }:
stdenv.mkDerivation {
  pname = "retro-crt-mpv";
  version = "2025-07-30";
  src = fetchFromGitHub {
    owner = "hhirtz";
    repo = "mpv-retro-shaders";
    rev = "f4ea211db4e2afb5f5dc5a3daf816749c9cd7f03";
    sha256 = "Y3R4GDDJl5Tles4SYRYDXnrjnKQelfXkS2g0McHLIV0=";
  };
  installPhase = ''
    mkdir -p $out
    cp *.glsl $out
  '';
}
