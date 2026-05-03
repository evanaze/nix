{
  pkgs,
  lib,
  username,
  ...
}: let
  pi-coding-agent = pkgs.callPackage ({
    buildNpmPackage,
    fetchFromGitHub,
    nix-update-script,
    versionCheckHook,
    writableTmpDirAsHomeHook,
    ripgrep,
    makeBinaryWrapper,
  }:
    buildNpmPackage (finalAttrs: {
      pname = "pi-coding-agent";
      version = "0.70.5";

      src = fetchFromGitHub {
        owner = "badlogic";
        repo = "pi-mono";
        tag = "v${finalAttrs.version}";
        hash = "sha256-Jn+hvS/DIwbwAff+UovdIVnmrb4o8gsC4IR24MnwF1I=";
      };

      npmDepsHash = "sha256-MZgcHJdGFGSNgQ26/24iA12FdmO7S5vWv4crSNFhHi0=";

      npmWorkspace = "packages/coding-agent";

      npmRebuildFlags = ["--ignore-scripts"];

      nativeBuildInputs = [
        makeBinaryWrapper
      ];

      buildPhase = ''
        runHook preBuild

        npx tsgo -p packages/ai/tsconfig.build.json
        npx tsgo -p packages/tui/tsconfig.build.json
        npx tsgo -p packages/agent/tsconfig.build.json
        npm run build --workspace=packages/coding-agent

        runHook postBuild
      '';

      postInstall = ''
        local nm="$out/lib/node_modules/pi-monorepo/node_modules"

        for ws in @mariozechner/pi-ai:packages/ai \
                  @mariozechner/pi-agent-core:packages/agent \
                  @mariozechner/pi-tui:packages/tui; do
          IFS=: read -r pkg src <<< "$ws"
          rm "$nm/$pkg"
          cp -r "$src" "$nm/$pkg"
        done

        find "$nm" -type l -lname '*/packages/*' -delete

        find "$nm/.bin" -xtype l -delete
      '';

      postFixup = "wrapProgram $out/bin/pi --prefix PATH : ${lib.makeBinPath [ripgrep]}";

      doInstallCheck = true;
      nativeInstallCheckInputs = [
        writableTmpDirAsHomeHook
        versionCheckHook
      ];
      versionCheckKeepEnvironment = ["HOME"];
      versionCheckProgram = "${placeholder "out"}/bin/pi";
      versionCheckProgramArg = "--version";

      passthru.updateScript = nix-update-script {};

      meta = {
        description = "Coding agent CLI with read, bash, edit, write tools and session management";
        homepage = "https://shittycodingagent.ai/";
        downloadPage = "https://www.npmjs.com/package/@mariozechner/pi-coding-agent";
        changelog = "https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/CHANGELOG.md";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [munksgaard];
        mainProgram = "pi";
      };
    })) {};

  pi-total-recall = pkgs.callPackage ({
    buildNpmPackage,
    fetchFromGitHub,
  }:
    buildNpmPackage {
      pname = "pi-total-recall";
      version = "1.4.0";

      src = fetchFromGitHub {
        owner = "samfoy";
        repo = "pi-total-recall";
        tag = "v1.4.0";
        hash = "sha256-QNEsx/4Vd441ldtQ/8xO/U6TDyuhrzqi+ifDC0/VhKU=";
      };

      npmDepsHash = "sha256-n8pahpoy5xAw8czBtqJuyazaBDF99AYRtgdChHtyHc0=";

      dontNpmBuild = true;
    }) {};

  babysitter-pi = pkgs.callPackage ({
    stdenv,
    fetchFromGitHub,
  }:
    stdenv.mkDerivation {
      pname = "babysitter-pi";
      version = "5.0.0";

      src = fetchFromGitHub {
        owner = "a5c-ai";
        repo = "babysitter-pi";
        tag = "release/main/v5.0.0-fd02a081ca5d";
        hash = "sha256-w/E10dkl8OWgyyVKn1diZ8PygNEc6sgiII4DE0bmjl8=";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/node_modules/@a5c-ai/babysitter-pi
        cp -r . $out/lib/node_modules/@a5c-ai/babysitter-pi/
        runHook postInstall
      '';
    }) {};
in {
  home-manager.users.${username} = {
    home.packages = [pi-coding-agent];

    home.activation.linkPiPackages = ''
      mkdir -p ~/.pi/packages
      ln -sfn ${pi-total-recall}/lib/node_modules/pi-total-recall ~/.pi/packages/pi-total-recall
      mkdir -p ~/.pi/packages/@a5c-ai
      ln -sfn ${babysitter-pi}/lib/node_modules/@a5c-ai/babysitter-pi ~/.pi/packages/@a5c-ai/babysitter-pi
    '';
  };
}
