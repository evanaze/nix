let
  module = {
    username,
    inputs,
    pkgs,
    system,
    ...
  }: {
    nixpkgs.overlays = [inputs.openviking.overlays.default];

    environment.systemPackages = with pkgs; [
      ov-cli
      inputs.self.packages.${system}.oh-my-opencode
    ];

    home-manager.users.${username} = {
      home.file.".openviking/ovcli.conf" = {
        text = ''
          {"url": "https://memory.spitz-pickerel.ts.net"}
        '';
      };

      home.file.".openviking/ovcli.settings.conf" = {
        text = ''
          {"language": "en"}
        '';
      };

      home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
        agents = {
          sisyphus.model = "opencode/claude-sonnet-4-5";
          oracle = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          librarian.model = "zai-coding-plan/glm-4.7";
          explore.model = "opencode/claude-haiku-4-5";
          multimodal-looker.model = "opencode/gemini-3-flash";
          prometheus = {
            model = "opencode/claude-opus-4-5";
            variant = "max";
          };
          metis = {
            model = "opencode/claude-opus-4-5";
            variant = "max";
          };
          momus = {
            model = "openai/gpt-5.2";
            variant = "medium";
          };
          atlas.model = "opencode/claude-sonnet-4-5";
        };
        categories = {
          visual-engineering.model = "opencode/gemini-3-pro";
          ultrabrain = {
            model = "openai/gpt-5.2-codex";
            variant = "xhigh";
          };
          artistry = {
            model = "opencode/gemini-3-pro";
            variant = "max";
          };
          quick.model = "opencode/claude-haiku-4-5";
          unspecified-low.model = "opencode/claude-sonnet-4-5";
          unspecified-high.model = "opencode/claude-sonnet-4-5";
          writing.model = "opencode/gemini-3-flash";
        };
      };

      programs.opencode = {
        enable = true;
        tui.theme = "catppuccin";
        settings = {
          autoupdate = true;
          lsp = true;
          plugin = [
            "openviking-opencode"
            "oh-my-opencode@3.0.1"
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
                baseURL = "https://llm.spitz-pickerel.ts.net:8724/v1";
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
