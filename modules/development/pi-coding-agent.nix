let
  remnicHost = "127.0.0.1";
  remnicPort = 4318;
  # remnicDaemonUrl = "http://${remnicHost}:${toString remnicPort}";

  module = {
    pkgs,
    username,
    ...
  }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        zstd
        openssl
      ];
    };

    home-manager.users.${username} = {
      home.file.".pi/agent/extensions/pi-permission-system/config.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/gotgenes/pi-permission-system/main/schemas/permissions.schema.json";
        permissionReviewLog = true;
        yoloMode = false;
        permission = {
          "*" = "ask";
          path = {
            "*" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
            "~/.config/sops/age/*" = "deny";
            "~/.config/sops/age/keys.txt" = "deny";
            "~/.ssh/*" = "deny";
            "~/.gnupg/*" = "deny";
            "/var/lib/sops-nix/*" = "deny";
          };
          read = "allow";
          grep = "allow";
          find = "allow";
          ls = "allow";
          web_search = "allow";
          web_fetch = "allow";
          ast_grep_search = "allow";
          hypa_grep = "allow";
          edit = "ask";
          write = "ask";
          bash = {
            "*" = "ask";
            "pwd" = "allow";
            "which *" = "allow";
            "ls *" = "allow";
            "cat *" = "allow";
            "grep *" = "allow";
            "git status*" = "allow";
            "git diff*" = "allow";
            "git branch*" = "allow";
            "git log --oneline*" = "allow";
            "git rev-parse*" = "allow";
            "git remote -v*" = "allow";
            "git show*" = "allow";
            "nix flake show*" = "allow";
            "nix flake metadata*" = "allow";
            "nix eval --json*" = "allow";
            "nix profile list*" = "allow";
            "nix profile show*" = "allow";
            "nix path-info*" = "allow";
            "nix search*" = "allow";
            "node2nix --help" = "allow";
            "node2nix --version" = "allow";
            "rm -rf *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
            "sudo *" = {
              action = "deny";
              reason = "Refusing privilege escalation from Pi.";
            };
            "git reset --hard*" = {
              action = "deny";
              reason = "Refusing destructive git history rewrites.";
            };
            "git clean -fd*" = {
              action = "deny";
              reason = "Refusing destructive git clean operations.";
            };
            "curl * | sh" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "wget * | sh" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "npm install -g *" = {
              action = "deny";
              reason = "Use the nix way to build npm packages: https://wiki.nixos.org/w/index.php?title=Node.js";
            };
          };
          mcp = {
            "*" = "ask";
            mcp_status = "allow";
            mcp_list = "allow";
          };
          skill = {
            "*" = "ask";
          };
          external_directory = {
            "*" = "ask";
            "/nix/store/*" = "allow";
            "/nix/var/nix/profiles/*" = "allow";
            "~/.pi/agent/npm/node_modules/*" = "allow";
            "~/.pi/agent/extensions/*" = "allow";
          };
        };
      };

      systemd.user.services.remnic = {
        Unit = {
          Description = "Remnic local memory server for Pi";
        };
        Service = {
          Type = "simple";
          ExecStart = "%h/.pi/agent/npm/node_modules/@remnic/cli/bin/remnic.cjs daemon install";
          Environment = [
            "REMNIC_HOST=${remnicHost}"
            "REMNIC_PORT=${toString remnicPort}"
            "REMNIC_MEMORY_DIR=%h/.local/share/remnic"
          ];
          Restart = "on-failure";
          RestartSec = 10;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      systemd.user.services.remnic-pi-install = {
        Unit = {
          Description = "Install Remnic Pi connector once";
          After = ["remnic.service"];
          Wants = ["remnic.service"];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "%h/.pi/agent/npm/node_modules/@remnic/cli/bin/remnic.cjs connectors install pi";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      programs.pi-coding-agent = {
        enable = true;
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
            "qwen3.6-35b-a3b"
            "gemma-4-12b-q4"
            "openai/gpt-5.5"
            "openai/gpt-5.4"
            "openai/gpt-5.4-mini"
            "openai/gpt-5.3-codex-spark"
          ];
          packages = [
            "npm:pi-subagents"
            "npm:pi-lens"
            "npm:pi-mcp-adapter"
            "npm:pi-intercom"
            "npm:pi-zentui"
            "npm:@gotgenes/pi-permission-system"
            "npm:@hypabolic/pi-hypa"
            "npm:@remnic/cli"
            "npm:@remnic/plugin-pi"
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
                  id = "qwen3.6-35b-a3b";
                  name = "Qwen 3.6 35B A3B";
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
                {
                  id = "gemma-4-12b-q4";
                  name = "Gemma 4 12B Q4";
                  contextWindow = 64000;
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
                {
                  id = "gpt-5.3-codex-spark";
                  name = "GPT-5.3 Codex Spark";
                  reasoning = false;
                  contextWindow = 400000;
                  maxTokens = 128000;
                }
              ];
            };
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
