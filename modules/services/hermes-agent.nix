let
  module = {
    inputs,
    lib,
    pkgs,
    config,
    username,
    ...
  }: let
    state-dir = "/mnt/eye/appdata/hermes";
    hermes-home = "${state-dir}/.hermes";
    dashboardPort = 9119;
    dashboardProxyPort = 9120;
    stackmagic-agent-port = 8643;
    default-obsidian-vault-path = "/mnt/eye/documents/Knowledge Base";
    stackmagic-profile = "stackmagic";
    stackmagic-profile-home = "${hermes-home}/profiles/${stackmagic-profile}";
    stackmagic-obsidian-vault-path = "/mnt/eye/documents/StackMagic";

    rtk-hermes = pkgs.python312Packages.buildPythonPackage {
      pname = "rtk-hermes";
      version = "1.2.3";
      src = pkgs.fetchFromGitHub {
        owner = "ogallotti";
        repo = "rtk-hermes";
        rev = "v1.2.3";
        hash = "sha256-7YRW6PODrCapfYLFn3DvgHAEME//RGC48GQt+s9ot0s=";
      };
      format = "pyproject";
      build-system = [pkgs.python312Packages.setuptools];
    };

    hermes-extra-dependency-groups = ["firecrawl" "messaging"];
    hermes-extra-python-packages = [rtk-hermes];
    mcp-stdio-packages = [
      pkgs.mcp-nixos
      pkgs.nodejs_22
      pkgs.uv
    ];
    mcp-stdio-commands = {
      actual = "${pkgs.nodejs_22}/bin/npx";
      donetick = "${pkgs.uv}/bin/uvx";
      nixos = lib.getExe pkgs.mcp-nixos;
    };
    hermes-package = pkgs.hermes-agent.override {
      extraDependencyGroups = hermes-extra-dependency-groups;
      extraPythonPackages = hermes-extra-python-packages;
    };
    bundled-obsidian-skill = "${hermes-package}/share/hermes-agent/skills/note-taking/obsidian";

    oh-my-hermers = pkgs.fetchFromGitHub {
      owner = "evanaze";
      repo = "oh-my-hermers";
      rev = "refs/heads/main";
      hash = "sha256-+43r25EpGq+wN2Rsj3+lBjccqogcuENN1luomawaMLg=";
    };

    stackmagic-skills = pkgs.fetchFromGitHub {
      owner = "evanaze";
      repo = "stackmagic-skills";
      rev = "refs/heads/main";
      private = true;
      hash = "sha256-TW2oXvmmlYMXQAsA4sx1xn8jCyVxqkXaa2aNmNf9sPM=";
    };

    common-hermes-settings = {
      model = {
        default = "gemma-4-12b-q4";
        provider = "local";
        context_length = 128000;
      };
      memory.provider = "openviking";
      browser = {
        cloud_provider = "local";
        camofox = {
          managed_persistence = true;
          rewrite_loopback_urls = false;
        };
      };
      web = {
        search_backend = "searxng";
        extract_backend = "firecrawl";
      };
      terminal.cwd = "${state-dir}/workspace";
      plugins.enabled = [
        "oh-my-hermes"
        "rtk-rewrite"
      ];
      file_read_max_chars = 30000;
      tool_output = {
        max_bytes = 20000;
        max_lines = 500;
      };
      compression = {
        enabled = true;
        threshold = 0.8;
        target_ratio = 0.2;
      };
      providers = {
        local = {
          base_url = "https://llm.spitz-pickerel.ts.net/v1";
          api_key = "none";
          model = "gemma-4-12b-q4";
          models = [
            "minicpm-v-4.6"
            "ornith-1.0-9b-q4"
            "gemma-4-12b-q4"
            "qwen3.6-35b-a3b"
          ];
        };
      };
      platforms.api_server.enabled = true;
      skills.disabled = [
        "airtable"
        "arxiv"
        "ascii-art"
        "ascii-video"
        "audiocraft-audio-generation"
        "baoyu-article-illustrator"
        "baoyu-comic"
        "baoyu-infographic"
        "blogwatcher"
        "claude-code"
        "claude-design"
        "codebase-inspection"
        "codex"
        "comfyui"
        "computer-use"
        "dspy"
        "gif-search"
        "github-auth"
        "github-code-review"
        "github-issues"
        "github-pr-workflow"
        "github-repo-management"
        "godmode"
        "heartmula"
        "hermes-s6-container-supervision"
        "jupyter-live-kernel"
        "kanban-codex-lane"
        "linear"
        "llama-cpp"
        "llm-wiki"
        "manim-video"
        "minecraft-modpack-server"
        "nano-pdf"
        "native-mcp"
        "notion"
        "obliteratus"
        "opencode"
        "openhue"
        "p5js"
        "petdex"
        "pixel-art"
        "pokemon-player"
        "polymarket"
        "powerpoint"
        "pretext"
        "python-debugpy"
        "requesting-code-review"
        "research-paper-writing"
        "serving-llms-vllm"
        "sketch"
        "songsee"
        "songwriting-and-ai-music"
        "spike"
        "spotify"
        "subagent-driven-development"
        "teams-meeting-pipeline"
        "test-driven-development"
        "touchdesigner-mcp"
        "webhook-subscriptions"
        "weights-and-biases"
        "writing-plans"
        "xurl"
        "yuanbao"
      ];
    };

    hermes-mcp-servers = {
      actual = {
        command = mcp-stdio-commands.actual;
        args = ["-y" "actual-mcp" "--enable-write"];
        env = {
          ACTUAL_PASSWORD = "\${env:ACTUAL_PASSWORD}";
          ACTUAL_SERVER_URL = "https://budget.spitz-pickerel.ts.net";
        };
        timeout = 60;
        connect_timeout = 30;
        tools = {
          exclude = [
            "create-category"
            "update-category"
            "delete-category"
            "create-category-group"
            "update-category-group"
            "delete-category-group"
            "create-payee"
            "update-payee"
            "delete-payee"
            "create-rule"
            "update-rule"
            "delete-rule"
            "update-transaction"
            "delete-transaction"
            "create-transaction"
          ];
        };
      };
      donetick = {
        command = mcp-stdio-commands.donetick;
        args = ["donetick-mcp"];
        env = {
          DONETICK_BASE_URL = "https://todo.spitz-pickerel.ts.net";
          DONETICK_USERNAME = "\${env:DONETICK_USERNAME}";
          DONETICK_PASSWORD = "\${env:DONETICK_PASSWORD}";
        };
        timeout = 60;
        connect_timeout = 30;
        tools = {
          exclude = [
            "update_label"
            "delete_label"
            "pause_chore_timer"
            "start_chore_timer"
            "list_circle_members"
          ];
        };
      };
      nixos.command = mcp-stdio-commands.nixos;
      nocodb-leads = {
        url = "https://nocodb.spitz-pickerel.ts.net/mcp/ncv4hm8lp1enp7fk";
        headers."xc-mcp-token" = "\${env:NOCODB_LEADS_MCP_TOKEN}";
      };
      nocodb-competitors = {
        url = "https://nocodb.spitz-pickerel.ts.net/mcp/nc7ekmhb4vs5tzmx";
        headers."xc-mcp-token" = "\${env:NOCODB_COMPETITORS_MCP_TOKEN}";
      };
    };

    default-profile-mcp-servers = lib.removeAttrs hermes-mcp-servers [
      "nocodb-leads"
      "nocodb-competitors"
    ];

    stackmagic-profile-mcp-servers = lib.removeAttrs hermes-mcp-servers [
      "actual"
      "nixos"
    ];

    default-profile-config =
      (pkgs.formats.yaml {}).generate "hermes-default-profile-config.yaml"
      (lib.recursiveUpdate default-profile-settings {
        mcp_servers = default-profile-mcp-servers;
      });

    default-profile-settings = lib.recursiveUpdate common-hermes-settings {
      plugins.enabled = [
        "disk-cleanup"
        "ntfy-platform"
      ];
    };

    stackmagic-profile-settings = lib.recursiveUpdate common-hermes-settings {
      skills = {
        external_dirs = ["${stackmagic-skills}"];
        disabled = [
          "evaluating-llms-harness"
          "himalaya"
          "huggingface-hub"
          "maps"
        ];
      };
      mcp_servers = stackmagic-profile-mcp-servers;
      platforms = {
        api_server.extra.port = stackmagic-agent-port;
        telegram.extra = {
          status_indicator = true;
          status_online = "🟢 Online";
          status_offline = "🔴 Offline";
          command_menu = {
            max_commands = 100;
            priority_mode = "replace";
            priority = ["stackmagic-accountability"];
          };
        };
      };
    };

    stackmagic-profile-config =
      (pkgs.formats.yaml {}).generate "hermes-stackmagic-profile-config.yaml"
      stackmagic-profile-settings;
  in {
    nixpkgs.overlays = [
      inputs.hermes-agent.overlays.default
    ];

    # Shared Hermes HOME for both gateway/dashboard (hermes user) and CLI (evanaze)
    # This lets the dashboard see CLI sessions and vice versa.
    # Use mkForce to override the upstream module's default
    environment.variables = {
      HERMES_HOME = lib.mkForce "${hermes-home}";
    };

    systemd.tmpfiles.rules = [
      "d ${hermes-home} 2770 hermes hermes -"
      "d ${hermes-home}/profiles 2770 hermes hermes -"
      "z ${hermes-home}/memories 2770 hermes hermes -"
      "d ${hermes-home}/skills 2770 hermes hermes -"
      "d ${hermes-home}/skills/.hub 2770 hermes hermes -"
      "Z ${hermes-home}/skills/.hub 2770 hermes hermes -"
      "a+ /home/${username} - - - - u:hermes:--x,m::--x"
      "a+ /home/${username}/.config - - - - u:hermes:--x,m::--x"

      "A+ /home/${username}/.config/nix - - - - u:hermes:rwX"
      "A+ /home/${username}/workspace - - - - u:hermes:rwX"

      "A+ /home/${username}/.config/nix - - - - d:u:hermes:rwX"
      "A+ /home/${username}/workspace - - - - d:u:hermes:rwX"
    ];

    users.users = {
      ${username}.extraGroups = ["hermes"];
      hermes.linger = true;
    };

    environment.systemPackages = [hermes-package];

    services.hermes-agent = {
      enable = true;
      createUser = true;
      stateDir = "${state-dir}";
      settings = default-profile-settings;
      mcpServers = default-profile-mcp-servers;
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        OBSIDIAN_VAULT_PATH = default-obsidian-vault-path;
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
      };
      environmentFiles = [config.sops.secrets."hermes/default-env".path];
      addToSystemPackages = true;
      extraPackages =
        mcp-stdio-packages
        ++ [stackmagic-skills];
      extraDependencyGroups = hermes-extra-dependency-groups;
      extraPythonPackages = hermes-extra-python-packages;
      extraPlugins = [oh-my-hermers];
    };

    sops.secrets."hermes/default-env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0640";
    };

    sops.secrets."hermes/stackmagic-env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0640";
    };

    systemd.services.hermes-agent = {
      after = [
        "camofox.service"
        "hermes-default-profile.service"
      ];
      environment.MESSAGING_CWD = lib.mkForce null;
      wants = [
        "camofox.service"
        "hermes-default-profile.service"
      ];
    };

    systemd.services.hermes-default-profile = {
      description = "Bootstrap Hermes default profile";
      after = [
        "systemd-tmpfiles-setup.service"
        "create-appdata-datasets.service"
        "zfs-mount.service"
      ];
      requires = [
        "systemd-tmpfiles-setup.service"
        "create-appdata-datasets.service"
        "zfs-mount.service"
      ];
      before = [
        "hermes-agent.service"
      ];
      wantedBy = ["multi-user.target"];
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
      };
      path = [pkgs.coreutils];
      restartTriggers = [default-profile-config];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "hermes";
        Group = "hermes";
        UMask = "0007";
      };
      script = ''
        set -euo pipefail
        install -D -m 0640 ${default-profile-config} "${hermes-home}/config.yaml"
      '';
    };

    systemd.services.hermes-stackmagic-profile = {
      description = "Bootstrap Hermes stackmagic profile";
      after = [
        "systemd-tmpfiles-setup.service"
        "create-appdata-datasets.service"
        "zfs-mount.service"
      ];
      requires = [
        "systemd-tmpfiles-setup.service"
        "create-appdata-datasets.service"
        "zfs-mount.service"
      ];
      before = [
        "hermes-agent.service"
        "hermes-stackmagic-gateway.service"
        "hermes-dashboard.service"
      ];
      wantedBy = ["multi-user.target"];
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
        OBSIDIAN_VAULT_PATH = stackmagic-obsidian-vault-path;
      };
      path = [
        pkgs.coreutils
        hermes-package
      ];
      restartTriggers = [stackmagic-profile-config];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "hermes";
        Group = "hermes";
        UMask = "0007";
        EnvironmentFile = config.sops.secrets."hermes/stackmagic-env".path;
      };
      script = ''
        set -euo pipefail

        if [ ! -d "${stackmagic-profile-home}" ]; then
          ${lib.getExe hermes-package} profile create --no-skills ${stackmagic-profile}
        fi

        touch "${stackmagic-profile-home}/.no-bundled-skills"
        chmod 0640 "${stackmagic-profile-home}/.no-bundled-skills"
        install -d -m 0750 "${stackmagic-profile-home}/skills/note-taking"

        if [ -e "${stackmagic-profile-home}/skills/note-taking/obsidian" ]; then
          chmod -R u+w "${stackmagic-profile-home}/skills/note-taking/obsidian" || true
          rm -rf "${stackmagic-profile-home}/skills/note-taking/obsidian"
        fi

        cp -r --no-preserve=mode "${bundled-obsidian-skill}" "${stackmagic-profile-home}/skills/note-taking/"
        chmod -R u+rwX "${stackmagic-profile-home}/skills/note-taking/obsidian"
        install -D -m 0640 ${stackmagic-profile-config} "${stackmagic-profile-home}/config.yaml"
      '';
    };

    systemd.services.hermes-stackmagic-gateway = {
      description = "Hermes Agent Gateway for stackmagic profile";
      after = [
        "camofox.service"
        "hermes-stackmagic-profile.service"
      ];
      path = mcp-stdio-packages;
      wants = [
        "camofox.service"
        "hermes-stackmagic-profile.service"
      ];
      wantedBy = ["multi-user.target"];
      environment = {
        HOME = state-dir;
        HERMES_HOME = stackmagic-profile-home;
        HERMES_MANAGED = "true";
        OBSIDIAN_VAULT_PATH = stackmagic-obsidian-vault-path;
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
      };
      serviceConfig = {
        Type = "simple";
        User = "hermes";
        Group = "hermes";
        EnvironmentFile = config.sops.secrets."hermes/stackmagic-env".path;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = "${lib.getExe hermes-package} gateway run";
    };

    systemd.services.hermes-dashboard = {
      after = [
        "hermes-stackmagic-profile.service"
        "hermes-stackmagic-gateway.service"
      ];
      path = mcp-stdio-packages;
      wants = [
        "hermes-stackmagic-profile.service"
        "hermes-stackmagic-gateway.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Hermes Agent Web Dashboard";
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        HERMES_DASHBOARD_PUBLIC_URL = "https://agent.spitz-pickerel.ts.net";
        OBSIDIAN_VAULT_PATH = default-obsidian-vault-path;
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
      };
      serviceConfig = {
        Type = "simple";
        User = "hermes";
        EnvironmentFile = config.sops.secrets."hermes/default-env".path;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = "${lib.getExe hermes-package} dashboard --host 0.0.0.0 --port ${toString dashboardPort} --no-open --skip-build";
    };

    services.caddy.virtualHosts."http://:${toString dashboardProxyPort}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString dashboardPort} {
          header_up Host {host}
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    systemd.services.hermes-tsserve = {
      after = [
        "caddy.service"
        "hermes-dashboard.service"
        "tailscaled.service"
      ];
      wants = [
        "caddy.service"
        "hermes-dashboard.service"
        "tailscaled.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Publish Hermes Dashboard via Tailscale Serve";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:hermes-dashboard || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:hermes-dashboard --https=443 http://127.0.0.1:${toString dashboardProxyPort}
      '';
    };

    systemd.services.sm-agent-tsserve = {
      after = [
        "hermes-stackmagic-gateway.service"
        "tailscaled.service"
      ];
      wants = [
        "hermes-stackmagic-gateway.service"
        "tailscaled.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Publish Hermes API Server with the StackMagic Agent port";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:stackmagic-agent || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:stackmagic-agent --https=443 http://127.0.0.1:${toString stackmagic-agent-port}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesHermesAgent = module;
    services = module;
  };
}
