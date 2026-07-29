{
  stdenv,
  lib,
  fetchurl,
  nodejs,
  makeWrapper,
}:

let
  version = "0.4.28";
in
stdenv.mkDerivation {
  pname = "dirac";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/dirac-cli/-/dirac-cli-${version}.tgz";
    hash = "sha512-rNHDVOKGsfoW1bGFxM/heGnB5VMG3pWVLUGG8paBx8CEIRxosIc+nS0+KfQzb4iwRaAWnkVKwU03hEZELr+1hw==";
  };

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "package";

  installPhase = ''
    runHook preInstall

    packageRoot=$out/share/node_modules/dirac-cli
    mkdir -p "$packageRoot" "$out/bin"

    cp -r . "$packageRoot/"

    makeWrapper ${lib.getExe nodejs} $out/bin/dirac \
      --add-flags "$packageRoot/dist/cli.mjs"

    runHook postInstall
  '';

  meta = {
    description = "Autonomous coding agent CLI - accurate & highly token efficient";
    homepage = "https://dirac.run";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "dirac";
  };
}