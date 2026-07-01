let
  remnicHost = "127.0.0.1";
  remnicPort = 4318;
  # remnicDaemonUrl = "http://${remnicHost}:${toString remnicPort}";

  module = {
    pkgs,
    username,
    ...
  }: {
    # programs.nix-ld = {
    #   enable = true;
    #   libraries = with pkgs; [
    #     stdenv.cc.cc
    #     zlib
    #     zstd
    #     openssl
    #   ];
    # };

    home-manager.users.${username} = {
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

      home.sessionPath = [
        "$HOME/.pi/agent/npm/node_modules/.bin"
      ];

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
          hypa_read = "allow";
          hypa_find = "allow";
          hypa_ls = "allow";
          # Keep hypa_shell gated like bash: it can execute arbitrary commands.
          todo = "allow";
          lens_diagnostics = "allow";
          lsp_diagnostics = "allow";
          lsp_navigation = "allow";
          module_report = "allow";
          read_symbol = "allow";
          read_enclosing = "allow";
          edit = "ask";
          write = "ask";
          bash = {
            "*" = "ask";
            "pwd" = "allow";
            "true" = "allow";
            "echo *" = "allow";
            "printf *" = "allow";
            "which *" = "allow";
            "command -v *" = "allow";
            "type *" = "allow";
            "alias *" = "allow";
            "ls *" = "allow";
            "cat *" = "allow";
            "head *" = "allow";
            "tail *" = "allow";
            "sort *" = "allow";
            "wc *" = "allow";
            "file *" = "allow";
            "readlink -f *" = "allow";
            "readelf -l *" = "allow";
            "patchelf --print-*" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "find *" = "allow";
            "find * -exec *" = "ask";
            "find * -delete*" = {
              action = "deny";
              reason = "Refusing destructive find deletion.";
            };
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
            "node --version" = "allow";
            "systemctl --user status*" = "allow";
            "systemctl --user is-enabled*" = "allow";
            "systemctl --user list-unit-files*" = "allow";
            "systemctl --user list-units*" = "allow";
            "systemctl --user show*" = "allow";
            "/run/current-system/sw/bin/systemd-analyze --user verify*" = "allow";
            "systemd-analyze --user verify*" = "allow";
            "journalctl --user *" = "allow";
            "pgrep -a -f *" = "allow";
            "ss -ltnp*" = "allow";
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
            "/run/current-system/sw/bin/*" = "allow";
            "~/.pi/agent/*" = "allow";
            "~/.pi-lens/*" = "allow";
            "~/.local/share/remnic/*" = "allow";
            "~/.config/systemd/user/*" = "allow";
            "/etc/systemd/user/*" = "allow";
            "/tmp/*" = "allow";
          };
        };
      };

      home.file.".config/remnic/config.json".text = builtins.toJSON {
        remnic = {
          memoryDir = "~/.local/share/remnic";
        };
        server = {
          host = remnicHost;
          port = remnicPort;
        };
      };

      systemd.user.services.remnic = {
        Unit = {
          Description = "Remnic local memory server for Pi";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.nodejs}/bin/node %h/.pi/agent/npm/node_modules/@remnic/server/bin/remnic-server.js";
          Environment = [
            "REMNIC_CONFIG_PATH=%h/.config/remnic/config.json"
          ];
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      # systemd.user.services.remnic-pi-install = {
      #   Unit = {
      #     Description = "Install Remnic Pi connector once";
      #     After = ["remnic.service"];
      #     Wants = ["remnic.service"];
      #   };
      #   Service = {
      #     Type = "oneshot";
      #     RemainAfterExit = true;
      #     ExecStart = "${pkgs.nodejs}/bin/node %h/.pi/agent/npm/node_modules/@remnic/cli/bin/remnic.cjs connectors install pi";
      #     Restart = "on-failure";
      #     RestartSec = 3;
      #   };
      #   Install = {
      #     WantedBy = ["default.target"];
      #   };
      # };
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
