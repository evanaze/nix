{
  stdenv,
  lib,
  fetchurl,
  bun,
  makeWrapper,
}:

let
  version = "3.0.1";
in
stdenv.mkDerivation {
  pname = "oh-my-opencode";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/oh-my-opencode/-/oh-my-opencode-${version}.tgz";
    hash = "sha256-nIDaJOqOhIMXPcYSDxp9vKA1gaaOcyuTSicYs61XUbQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "package";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/node_modules/oh-my-opencode
    cp -r . $out/share/node_modules/oh-my-opencode/

    makeWrapper ${lib.getExe bun} $out/bin/oh-my-opencode \
      --add-flags "$out/share/node_modules/oh-my-opencode/dist/cli/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Batteries-included OpenCode plugin with multi-model orchestration";
    homepage = "https://github.com/opensoft/oh-my-opencode";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "oh-my-opencode";
  };
}
