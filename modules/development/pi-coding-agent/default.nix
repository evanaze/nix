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
        ''}
      '';
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
          nodejs
          mcp-nixos
        ];
        settings = {
          defaultProvider = "llama-local";
          defaultModel = "ornith-1.0-9b-q4";
          defaultThinkingLevel = "medium";
          enabledModels = [
            "ornith-1.0-9b-q4"
            "ornith-1.0-9b-q8"
            "qwen3.6-35b-a3b"
            "gemma-4-12b-q4"
            "gpt-5.5"
            "gpt-5.4"
            "gpt-5.4-mini"
            "gpt-5.3-codex-spark"
          ];
          packages = [
            "npm:pi-mcp-adapter"
            "npm:pi-zentui"
            "npm:@gotgenes/pi-permission-system"
            "npm:@hypabolic/pi-hypa"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"
            "npm:@juicesharp/rpiv-web-tools"
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
                  id = "ornith-1.0-9b-q4";
                  name = "Ornith 1.0 9B Q4_K_M";
                  reasoning = true;
                  contextWindow = 128000;
                  maxTokens = 4096;
                }
                {
                  id = "ornith-1.0-9b-q8";
                  name = "Ornith 1.0 9B Q8";
                  reasoning = true;
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
                {
                  id = "qwen3.6-35b-a3b";
                  name = "Qwen 3.6 35B A3B";
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
                {
                  id = "qwen3.6-reap";
                  name = "Qwen 3.6 28B A3B REAP";
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
                {
                  id = "gemma-4-12b-q4";
                  name = "Gemma 4 12B Q4";
                  contextWindow = 128000;
                  maxTokens = 4096;
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
