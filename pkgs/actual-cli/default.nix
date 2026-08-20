{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
}: let
  version = "26.8.1";
  lockfile = ./package-lock.json;
in
  buildNpmPackage {
    pname = "actual-cli";

    src = fetchurl {
          url = "https://registry.npmjs.org/@actual-app/cli/-/cli-${version}.tgz";
          hash = "sha256-32ZdtebuEqgycoMbTRuBoAGAK+srq8XUAL8dHfMoaDo=";
        };

    npmDepsHash = "sha256-pH6uVnERlG5QMzsx5wj2CepoCfEyhR3/KJQ5M3y/lsQ=";
    dontNpmBuild = true;

    buildInputs = [nodejs];
    nativeBuildInputs = [makeWrapper];

    postPatch = ''
      cp ${lockfile} ./package-lock.json
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/actual-cli $out/bin
      cp -r dist node_modules $out/lib/actual-cli/
      makeWrapper ${lib.getExe nodejs} $out/bin/actual \
        --add-flags "$out/lib/actual-cli/dist/cli.js"
      runHook postInstall
    '';

    meta.mainProgram = "actual";
  };
