{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  makeWrapper,
}:
buildNpmPackage {
  pname = "falkordb-browser";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "FalkorDB";
    repo = "falkordb-browser";
    rev = "v2.5.2";
    hash = "sha256-yKF9WlU5LI4ytc6yQ57sXVpxOh0Rl4lFK63BRkNHeMo=";
  };

  nodejs = nodejs_24;

  npmDepsHash = "sha256-ZGTMl1Jp/jBWrr6qCVmZhdof7/4g29U8xI8Q5hLVdMU=";
  npmDepsFetcherVersion = 2;

  # package.json build script: `next build --webpack`
  npmBuildScript = "build";

  # Silence Next.js telemetry banner during the (noisy) build.
  postPatch = ''
    export NEXT_TELEMETRY_DISABLED=1

    # Fix broken lockfile: react-syntax-highlighter requires refractor@^3.6.0
    # but the lockfile resolves it to 4.9.0, violating semver. npm ci rejects
    # this mismatch when offline. Patch the dependency range to accept 4.x.
    substituteInPlace package-lock.json \
      --replace-fail '"refractor": "^3.6.0"' '"refractor": "^4.0.0"'
  '';

  # The upstream Docker image copies .next/standalone + .next/static + public
  # into a single directory and runs `node server.js`. `next build --webpack`
  # produces exactly those artifacts, so we mirror the image layout.
  installPhase = ''
    runHook preInstall

    mkdir -p ''$out/share/falkordb-browser
    cp -r .next/standalone .next/static public ''$out/share/falkordb-browser/

    # server.js is emitted by `next build` inside the standalone tree.
    makeWrapper ${lib.getExe nodejs_24} ''$out/bin/falkordb-browser \
      --add-flags "''$out/share/falkordb-browser/server.js"

    runHook postInstall
  '';

  meta = {
    description = "FalkorDB graph database browser (Next.js web UI)";
    homepage = "https://www.falkordb.com";
    license = lib.licenses.sspl;
    platforms = lib.platforms.linux;
    mainProgram = "falkordb-browser";
  };
}