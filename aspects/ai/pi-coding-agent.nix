{
  pkgs,
  lib,
  config,
  username,
  inputs,
  ...
}: let
  pi-coding-agent = pkgs.callPackage (
    {
      buildNpmPackage,
      fetchFromGitHub,
      nix-update-script,
      versionCheckHook,
      writableTmpDirAsHomeHook,
      ripgrep,
      nodejs,
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

          install -Dm644 /dev/stdin "$out/share/pi/default-config.json" <<'EOF'
          {
            "providers": {
              "llama-cpp": {
                "baseUrl": "https://llm.spitz-pickerel.ts.net:${toString config.services.llama-swap.port}/v1",
                "api": "openai-completions",
                "apiKey": "swagswagswagswagswag",
                "models": [
                  {
                    "id": "qwen3.6-35b-a3b",
                    "name": "Qwen3.6-35b-a3b (Local)",
                    "reasoning": false,
                    "input": ["text"],
                    "contextWindow": 32768,
                    "cost": {
                      "input": 0,
                      "output": 0,
                      "cacheRead": 0,
                      "cacheWrite": 0
                    }
                  }
                ]
              }
            }
          }
          EOF
        '';

        postFixup = ''
          wrapProgram $out/bin/pi \
            --prefix PATH : ${
            lib.makeBinPath [
              ripgrep
              nodejs
            ]
          } \
            --run 'export NPM_CONFIG_PREFIX="$HOME/.npm-global"'
        '';

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
      })
  ) {};
in {
  home-manager.users.${username} = {
    home.packages = [pi-coding-agent];

    home.activation.installPiPackages = inputs.home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
      for pipkg in @sinamtz/pi-mempalace \
                  pi-subagents \
                  pi-autoskills \
                  pi-mempalace \
                  pi-web-access \
                  taskplane \
                  pi-lens \
                  pi-markdown-preview \
                  pi-powerline-footer \
                  pi-mcp-adapter; do
        $DRY_RUN_CMD ${pi-coding-agent}/bin/pi install npm:$pipkg
      done
    '';

    home.activation.setLocalModel = inputs.home-manager.lib.hm.dag.entryAfter ["installPiPackages"] ''
      target="$HOME/.pi/agent/models.json"
      mkdir -p "$(dirname "$target")"
      install -m 600 ${pi-coding-agent}/share/pi/default-config.json "$target"
    '';
  };
}
