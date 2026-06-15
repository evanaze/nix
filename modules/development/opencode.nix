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
          sisyphus = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          oracle = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          librarian = {
            model = "opencode/big-pickle";
          };
          explore = {
            model = "opencode/gpt-5-nano";
          };
          "multimodal-looker" = {
            model = "openai/gpt-5.2";
          };
          prometheus = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          metis = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          momus = {
            model = "openai/gpt-5.2";
            variant = "medium";
          };
          atlas = {
            model = "openai/gpt-5.2";
          };
        };
        categories = {
          "visual-engineering" = {
            model = "openai/gpt-5.2";
            variant = "high";
          };
          ultrabrain = {
            model = "openai/gpt-5.2-codex";
            variant = "xhigh";
          };
          artistry = {
            model = "openai/gpt-5.2";
            variant = "max";
          };
          quick = {
            model = "opencode/big-pickle";
          };
          "unspecified-low" = {
            model = "openai/gpt-5.2-codex";
            variant = "medium";
          };
          "unspecified-high" = {
            model = "openai/gpt-5.2-codex";
            variant = "medium";
          };
          writing = {
            model = "openai/gpt-5.2";
          };
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
