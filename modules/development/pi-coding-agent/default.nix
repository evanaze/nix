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
          defaultModel = "ornith-1.0-9b-q8";
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
        toolInputPreviewMaxLength = 800;
        toolTextSummaryMaxLength = 160;
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
          hypa_shell = "ask";
          remnic."*" = "allow";
          ask_user_question = "allow";
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
            "git blame*" = "allow";
            "git describe*" = "allow";
            "git grep*" = "allow";
            "git ls-files*" = "allow";
            "nix flake show*" = "allow";
            "nix flake metadata*" = "allow";
            "nix eval --json*" = "allow";
            "nix profile list*" = "allow";
            "nix profile show*" = "allow";
            "nix path-info*" = "allow";
            "nix search*" = "allow";
            "nix build*" = "allow";
            "nix-instantiate --eval*" = "allow";
            "nix show-config*" = "allow";
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
            "rm -r *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
            "rm -fr *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
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
            "curl * | bash" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "wget * | sh" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "wget * | bash" = {
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
            write = "allow";
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
