{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
  ripgrep,
}: let
  version = "0.4.28";

  # Vendored lockfile (generated with: npm install --package-lock-only --ignore-scripts --production)
  lockfile = ./package-lock.json;
in
  buildNpmPackage {
    pname = "dirac";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/dirac-cli/-/dirac-cli-${version}.tgz";
      hash = "sha512-rNHDVOKGsfoW1bGFxM/heGnB5VMG3pWVLUGG8paBx8CEIRxosIc+nS0+KfQzb4iwRaAWnkVKwU03hEZELr+1hw==";
    };

    sourceRoot = "package";

    npmDepsHash = "sha256-Z/wY1YLK5FXhCYT6LeOW78Xb9xW7qSNloSbUWmPZIJ0=";

    dontNpmBuild = true;

    buildInputs = [nodejs];
    nativeBuildInputs = [makeWrapper];

    postPatch = ''
      cp ${lockfile} ./package-lock.json
    '';

    preBuild = ''
      # Replace @vscode/ripgrep with shim using system ripgrep.
      # Must run AFTER npm deps are extracted (preBuild = after configure).
      rm -rf node_modules/@vscode/ripgrep
      mkdir -p node_modules/@vscode/ripgrep
      cat > node_modules/@vscode/ripgrep/index.js << 'EOF'
      module.exports.rgPath = "${ripgrep}/bin/rg";
      EOF
      cat > node_modules/@vscode/ripgrep/package.json << EOF
      {
        "name": "@vscode/ripgrep",
        "version": "1.15.9",
        "main": "index.js"
      }
      EOF
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/node_modules/dirac-cli $out/bin
      cp -r . $out/share/node_modules/dirac-cli/

      makeWrapper ${lib.getExe nodejs} $out/bin/dirac \
        --set NODE_PATH $out/share/node_modules/dirac-cli/node_modules \
        --set DIRAC_NO_AUTO_UPDATE 1 \
        --add-flags "$out/share/node_modules/dirac-cli/dist/cli.mjs"

      runHook postInstall
    '';

    meta = {
      description = "Autonomous coding agent CLI - accurate & highly token efficient";
      homepage = "https://dirac.run";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.asl20;
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "dirac";
    };
  }