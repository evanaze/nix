let
  module = {
    username,
    inputs,
    pkgs,
    system,
    ...
  }: let
    openvikingSource = inputs.openviking.packages.${system}.openviking.src;
    openvikingOpencodePlugin = pkgs.writeText "openviking-opencode.mjs" (
      builtins.replaceStrings
      [
        ''  // installed but no config file — cannot start''
      ]
      [
        ''  // If the CLI is configured for a remote server, do not try to
  // auto-start a local server or require local server credentials. The
  // remote may simply be offline, and `~/.openviking/ov.conf` is only needed
  // for local server startup.
  const cliConfig = join(homedir(), ".openviking", "ovcli.conf")
  if (existsSync(cliConfig)) {
    try {
      const url = JSON.parse(readFileSync(cliConfig, "utf8"))?.url
      const host = url ? new URL(url).hostname : null
      if (host && !["localhost", "127.0.0.1", "::1"].includes(host)) return false
    } catch {}
  }

  // installed but no config file — cannot start''
      ]
      (builtins.readFile "${openvikingSource}/examples/opencode/plugin/index.mjs")
    );
  in {
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

      home.file.".config/opencode/plugins/openviking-opencode.mjs".source = openvikingOpencodePlugin;

      home.file.".config/opencode/plugins/skills/openviking/SKILL.md".source =
        "${openvikingSource}/examples/opencode/plugin/skills/openviking/SKILL.md";

      home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
        agents = {
          sisyphus = {
            model = "openai/gpt-5.5";
            variant = "high";
          };
          oracle = {
            model = "openai/gpt-5.5";
            variant = "high";
          };
          librarian = {
            model = "openai/gpt-5.5-fast";
          };
          explore = {
            model = "openai/gpt-5.4-mini-fast";
          };
          "multimodal-looker" = {
            model = "openai/gpt-5.5";
          };
          prometheus = {
            model = "openai/gpt-5.5";
            variant = "high";
          };
          metis = {
            model = "openai/gpt-5.5";
            variant = "high";
          };
          momus = {
            model = "openai/gpt-5.5";
            variant = "medium";
          };
          atlas = {
            model = "openai/gpt-5.5-fast";
          };
        };
        categories = {
          "visual-engineering" = {
            model = "openai/gpt-5.5";
            variant = "high";
          };
          ultrabrain = {
            model = "openai/gpt-5.3-codex-spark";
            variant = "xhigh";
          };
          artistry = {
            model = "openai/gpt-5.5-pro";
            variant = "max";
          };
          quick = {
            model = "openai/gpt-5.5-fast";
          };
          "unspecified-low" = {
            model = "openai/gpt-5.3-codex-spark";
            variant = "medium";
          };
          "unspecified-high" = {
            model = "openai/gpt-5.3-codex-spark";
            variant = "medium";
          };
          writing = {
            model = "openai/gpt-5.5";
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
