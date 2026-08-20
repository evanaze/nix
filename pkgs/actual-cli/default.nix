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
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@actual-app/cli/-/cli-${version}.tgz";
      hash = "sha256-F/OHIQmYEjeyuY+j6wcp8UGuRjOuO8OnV7PA34UtQNU=";
    };

    sourceRoot = "package";

    npmDepsHash = "sha256-uu+n2n+lr9FvE+sktLJ+eq03ifqEKoYkBHOZqe/M11g=";
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
  }
