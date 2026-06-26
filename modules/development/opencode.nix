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
    openvikingSource = inputs.openviking.packages.${system}.openviking.src;
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
    openvikingOpencodePlugin = pkgs.writeText "openviking-opencode.mjs" (
      builtins.replaceStrings
      [
        "// installed but no config file — cannot start"
      ]
      [
        ''
          // If the CLI is configured for a remote server, do not try to
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

    sops.secrets."nocodb/env" = {
      owner = username;
      mode = "0400";
    };

    environment.systemPackages = with pkgs; [
      ov-cli
      inputs.self.packages.${system}.oh-my-openagent
    ];

    home-manager.users.${username} = {
      home.file = {
        ".openviking/ovcli.conf".text = ''
          {"url": "https://memory.spitz-pickerel.ts.net"}
        '';

        ".openviking/ovcli.settings.conf".text = ''
          {"language": "en"}
        '';

        ".config/opencode/plugins/openviking-opencode.mjs".source = openvikingOpencodePlugin;

        ".config/opencode/plugins/skills/openviking/SKILL.md".source = "${openvikingSource}/examples/opencode/plugin/skills/openviking/SKILL.md";

        ".config/opencode/oh-my-openagent.json".text = builtins.toJSON {
          "$schema" = "https://unpkg.com/oh-my-openagent@4.13.0/schema.json";
          agents = {
            sisyphus = {
              model = "openai/chat-gpt-5.4";
              variant = "high";
            };
            hephaestus.model = "openai/chat-gpt-5.5";
            oracle.model = "openai/chat-gpt-5.5";
            prometheus.model = "openai/chat-gpt-5.5";
            atlas.model = "openai/chat-gpt-5.4";
            librarian.model = "openai/chat-gpt-5.4";
            explore.model = "openai/chat-gpt-5.4";
            "multimodal-looker".model = "openai/chat-gpt-5.4";
            momus = {
              model = "openai/chat-gpt-5.5";
              variant = "high";
            };
          };
          categories = {
            "visual-engineering".model = "openai/chat-gpt-5.5";
            ultrabrain = {
              model = "openai/chat-gpt-5.5";
              variant = "high";
            };
            artistry.model = "openai/chat-gpt-5.5";
            quick.model = "openai/chat-gpt-5.4-mini";
            "unspecified-low".model = "openai/chat-gpt-5.4-mini";
            "unspecified-high".model = "openai/chat-gpt-5.5";
            writing.model = "openai/chat-gpt-5.4";
          };
        };
      };

      programs.mcp = {
        enable = true;
        servers = {
          nixos = {
            command = "mcp-nixos";
          };
          nocodb-leads = {
            url = "https://nocodb.spitz-pickerel.ts.net/mcp/ncv4hm8lp1enp7fk";
            headers."xc-mcp-token" = "{env:NOCODB_LEADS_MCP_TOKEN}";
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
            "oh-my-openagent@4.13.0"
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
