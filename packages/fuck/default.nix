{
  lib,
  stdenv,
  ncurses,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fuck";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild
    $CC -O2 -Wall -Wextra \
      $(pkg-config --cflags ncursesw) \
      fuck.c \
      -o fuck \
      $(pkg-config --libs ncursesw) \
      -lm
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 fuck $out/bin/fuck
    runHook postInstall
  '';

  meta = {
    description = "Terminal glitch animation written in C with ncurses";
    platforms = lib.platforms.unix;
    mainProgram = "fuck";
  };
})
