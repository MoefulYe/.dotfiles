{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {

  pname = "zju-connect";
  version = "0.9.0";

  src = fetchFromGitHub ({
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-LrupxRFobVzzOiQCznnaIH17sTsnzjiMVnWDMyN0dwY=";
  });

  vendorHash = "sha256-G+glwXw3zDA4XYWUnrkyG55PicHDutXRe7ZzdJGirZA=";

  meta = with lib; {
    description = "Zhejiang University RVPN Client in Go";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = with licenses; [ agpl3Only ];
    mainProgram = "zju-connect";
    platforms = platforms.all;
  };

}
