let
  module = {
    config,
    username,
    inputs,
    lib,
    pkgs,
    system,
    ...
  }: let
    nocodbEnvFile = config.sops.secrets."nocodb/env".path;
    opencodeWithNocodbEnv = pkgs.symlinkJoin {
      inherit (pkgs.opencode) meta;
      name = "${lib.getName pkgs.opencode}-with-nocodb-env-${lib.getVersion pkgs.opencode}";
      paths = [pkgs.opencode];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/opencode \
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
    sops.secrets."nocodb/env" = {
      owner = username;
      mode = "0400";
    };

    environment.systemPackages = [
      inputs.self.packages.${system}.oh-my-openagent
    ];

    home-manager.users.${username} = {
      home.file = {
        ".config/opencode/oh-my-openagent.json".text = builtins.toJSON {
          "$schema" = "https://unpkg.com/oh-my-openagent@4.19.3/schema.json";
          agents = {
            sisyphus = {
              model = "deepseek/deepseek-v4-flash";
              variant = "high";
            };
            hephaestus.model = "deepseek/deepseek-v4-pro";
            oracle.model = "deepseek/deepseek-v4-pro";
            prometheus.model = "deepseek/deepseek-v4-pro";
            atlas.model = "deepseek/deepseek-v4-pro";
            librarian.model = "deepseek/deepseek-v4-flash";
            explore.model = "deepseek/deepseek-v4-flash";
            "multimodal-looker".model = "deepseek/deepseek-v4-flash";
            momus = {
              model = "deepseek/deepseek-v4-flash";
              variant = "high";
            };
          };
          categories = {
            "visual-engineering".model = "openai/gpt-5.5";
            ultrabrain = {
              model = "openai/gpt-5.5";
              variant = "high";
            };
            artistry.model = "openai/gpt-5.5";
            quick.model = "openai/gpt-5.4-mini";
            "unspecified-low".model = "openai/gpt-5.4-mini";
            "unspecified-high".model = "openai/gpt-5.5";
            writing.model = "openai/gpt-5.4";
          };
        };
      };

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = opencodeWithNocodbEnv;
        extraPackages = [pkgs.mcp-nixos];
        web.environmentFile = nocodbEnvFile;
        tui.theme = "catppuccin";
        settings = {
          autoupdate = true;
          lsp = true;
          plugin = [
            "oh-my-openagent@4.19.3"
          ];
          compaction = {
            auto = true;
            prune = true;
            reserved = 8000;
          };
          provider = {
            llama-local = {
              name = "Llama Swap";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = "https://llm.spitz-pickerel.ts.net/v1";
              };
              models = {
                "gemma-4-12b-q4" = {
                  name = "gemma-4-12b-q4";
                  limit = {
                    context = 64000;
                    output = 4096;
                  };
                };
                "qwen3.6-35b-a3b" = {
                  name = "qwen3.6-35b-a3b";
                  limit = {
                    context = 64000;
                    output = 4096;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentOpencode = module;
    development = module;
  };
}
