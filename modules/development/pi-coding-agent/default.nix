let
  module = {
    pkgs,
    username,
    config,
    lib,
    ...
  }: let
    nocodbEnvFile = config.sops.secrets."nocodb/env".path;
    piWithNocodbEnv = pkgs.symlinkJoin {
      inherit (pkgs.pi-coding-agent) meta;
      name = "${lib.getName pkgs.pi-coding-agent}-with-nocodb-env-${lib.getVersion pkgs.pi-coding-agent}";
      paths = [pkgs.pi-coding-agent];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --run ${lib.escapeShellArg ''
          if [ -f ${lib.escapeShellArg nocodbEnvFile} ]; then
            set -a
            . ${lib.escapeShellArg nocodbEnvFile}
            set +a
          fi

          export NPM_CONFIG_CACHE="$HOME/.cache/pi/npm"
          export npm_config_cache="$NPM_CONFIG_CACHE"
          export npm_config_nodedir=${lib.escapeShellArg (lib.getDev pkgs.nodejs)}
          export npm_config_node_gyp=${lib.escapeShellArg "${pkgs.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js"}
          export npm_config_python=${lib.escapeShellArg (lib.getExe pkgs.python3)}
          export PYTHON="$npm_config_python"
        ''}
      '';
    };
    local-agent-builder-skill = pkgs.fetchFromGitHub {
      name = "local-agent-builder";
      owner = "kyuz0";
      repo = "local-agent-builder";
      rev = "e5b048925acbf9a981ddb28bf61a72a46f60e34a";
      hash = "sha256-CJ2RIO8x5UsqKBG8962EdeQ5BNmCThpgnubI+Y1nQDg=";
    };
  in {
    programs.nix-ld.enable = true;

    sops.secrets."nocodb/env" = {
      owner = username;
      mode = "0400";
    };

    home-manager.users.${username} = {
      programs.pi-coding-agent = {
        enable = true;
        package = piWithNocodbEnv;
        extraPackages = with pkgs; [
          bun
          gcc
          gnumake
          nodejs
          mcp-nixos
          python3
        ];
        settings = {
          defaultProvider = "llama-local";
          defaultModel = "qwen3.6-ternary";
          defaultThinkingLevel = "medium";
          enabledModels = [
            "gemma-4-12b-q4"
            "gemma-4-21b-q4"
            "glm-4.7-flash-reap-23b-q4"
            "lfm2.5-8b-balanced"
            "lfm2.5-8b-bf16"
            "minicpm-v-4.6"
            "ornith-1.0-9b-q4"
            "ornith-1.0-9b-q6"
            "ornith-1.0-9b-q8"
            "qwen3.6-ternary"
            "gpt-5.5"
            "gpt-5.4"
            "gpt-5.4-mini"
            "gpt-5.3-codex-spark"
          ];
          packages = [
            "npm:pi-mcp-adapter"
            "npm:pi-zentui"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"
            "npm:@juicesharp/rpiv-web-tools"
            "npm:@plannotator/pi-extension"
          ];
          skills = [
            "${local-agent-builder-skill}/skills"
          ];
        };
        models = {
          providers = {
            "llama-local" = {
              api = "openai-completions";
              apiKey = "none";
              baseUrl = "https://llm.spitz-pickerel.ts.net/v1";
              compat = {
                supportsDeveloperRole = false;
                supportsReasoningEffort = false;
              };
              models = [
                {
                  id = "gemma-4-12b-q4";
                  name = "Gemma 4 12B Q4";
                  contextWindow = 128000;
                  maxTokens = 8192;
                }
                {
                  id = "gemma-4-21b-q4";
                  name = "Gemma 4 21B Q4";
                  contextWindow = 32768;
                  maxTokens = 8192;
                }
                {
                  id = "glm-4.7-flash-reap-23b-q4";
                  name = "GLM 4.7 Flash REAP 23B Q4";
                  contextWindow = 32768;
                  maxTokens = 8192;
                }
                {
                  id = "lfm2.5-8b-balanced";
                  name = "LFM 2.5 8B Balanced";
                  contextWindow = 128000;
                  maxTokens = 8192;
                }
                {
                  id = "lfm2.5-8b-bf16";
                  name = "LFM 2.5 8B BF16";
                  contextWindow = 32768;
                  maxTokens = 8192;
                }
                {
                  id = "minicpm-v-4.6";
                  name = "MiniCPM-V 4.6";
                  contextWindow = 8192;
                  maxTokens = 4096;
                }
                {
                  id = "ornith-1.0-9b-q4";
                  name = "Ornith 1.0 9B Q4_K_M";
                  reasoning = true;
                  contextWindow = 128000;
                  maxTokens = 8192;
                }
                {
                  id = "ornith-1.0-9b-q6";
                  name = "Ornith 1.0 9B Q6_K";
                  reasoning = true;
                  contextWindow = 128000;
                  maxTokens = 8192;
                }
                {
                  id = "ornith-1.0-9b-q8";
                  name = "Ornith 1.0 9B Q8_0";
                  reasoning = true;
                  contextWindow = 65536;
                  maxTokens = 8192;
                }
                {
                  id = "qwen3.6-ternary";
                  name = "Qwen 3.6 Ternary Bonsai 27B";
                  contextWindow = 128000;
                  maxTokens = 8192;
                }
              ];
            };
            "openai" = {
              api = "openai-completions";
              baseUrl = "https://api.openai.com/v1";
              models = [
                {
                  id = "gpt-5.5";
                  name = "GPT-5.5";
                  reasoning = true;
                  contextWindow = 400000;
                  maxTokens = 128000;
                }
                {
                  id = "gpt-5.4";
                  name = "GPT-5.4";
                  reasoning = true;
                  contextWindow = 400000;
                  maxTokens = 128000;
                }
                {
                  id = "gpt-5.4-mini";
                  name = "GPT-5.4 Mini";
                  reasoning = true;
                  contextWindow = 400000;
                  maxTokens = 128000;
                }
              ];
            };
          };
        };
      };

      home.sessionPath = [
        "$HOME/.pi/agent/npm/node_modules/.bin"
      ];

      home.file.".pi/IDENTITY.md".text = ''
        # Identity

        ## Name
        Evan

        ## Communication Preferences
        - Address me by name
        - Be direct and concise
        - Use clear, actionable language

        ## Coding Preferences
        - **Test-first**: Write tests before implementation
        - **Clean code**: Prefer minimal, readable solutions
        - **Structure**: Clear organization with good separation of concerns
        - **Documentation**: Include comments for complex logic

        ## Work Style
        - Value efficiency and correctness
        - Prefer working in small, testable increments
        - Like clear feedback loops

        ## Interests & Context
        - Working with Nix configuration management
        - AI coding assistants and memory systems
        - Software development and automation

        ## Notes
        - This identity file was created on 2026-07-01
        - Remnic is configured and active
        - Identity continuity is enabled
      '';
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
