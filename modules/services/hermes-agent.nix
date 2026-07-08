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
    default-obsidian-vault-path = "/mnt/eye/documents/Knowledge Base";
    research-profile = "research";
    research-profile-home = "${hermes-home}/profiles/${research-profile}";
    research-obsidian-vault-path = "/mnt/eye/documents/StackMagic";

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

    hermes-extra-dependency-groups = ["firecrawl"];
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

    stackmagic-research = pkgs.fetchFromGitHub {
      owner = "evanaze";
      repo = "stackmagic-research";
      rev = "refs/heads/main";
      private = true;
      hash = "sha256-x2DGiNUd3Tc28QZov92hjW0MnNy55Eyiq9UgML+Tyxc=";
    };

    stackmagic-accountability = pkgs.fetchFromGitHub {
      owner = "evanaze";
      repo = "stackmagic-accountability";
      rev = "refs/heads/main";
      private = true;
      hash = "sha256-ulVrEWLxkjMw08QKavFJ0dcN5faO6FMfOqihYa56Uvg=";
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
        backend = "firecrawl";
        search_backend = "firecrawl";
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

    research-profile-mcp-servers = lib.removeAttrs hermes-mcp-servers [
      "actual"
      "nixos"
    ];

    default-profile-settings = lib.recursiveUpdate common-hermes-settings {
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
      plugins.enabled = [
        "disk-cleanup"
        "ntfy-platform"
      ];
    };

    research-profile-settings = lib.recursiveUpdate common-hermes-settings {
      skills.external_dirs = [
        "${stackmagic-accountability}"
        "${stackmagic-research}"
      ];
      mcp_servers = research-profile-mcp-servers;
    };

    research-profile-config =
      (pkgs.formats.yaml {}).generate "hermes-research-profile-config.yaml"
      research-profile-settings;
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

    environment.systemPackages = [
      hermes-package
    ];

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
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
      extraPackages =
        mcp-stdio-packages
        ++ [
          stackmagic-accountability
          stackmagic-research
        ];
      extraDependencyGroups = hermes-extra-dependency-groups;
      extraPythonPackages = hermes-extra-python-packages;
      extraPlugins = [oh-my-hermers];
    };

    sops.secrets."hermes/env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0640";
    };

    systemd.services.hermes-agent = {
      after = [
        "camofox.service"
        "hermes-research-profile.service"
      ];
      environment.MESSAGING_CWD = lib.mkForce null;
      wants = [
        "camofox.service"
        "hermes-research-profile.service"
      ];
    };

    systemd.services.hermes-research-profile = {
      description = "Bootstrap Hermes research profile";
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
        "hermes-dashboard.service"
      ];
      wantedBy = ["multi-user.target"];
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
        OBSIDIAN_VAULT_PATH = research-obsidian-vault-path;
      };
      path = [
        pkgs.coreutils
        hermes-package
      ];
      restartTriggers = [research-profile-config];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "hermes";
        Group = "hermes";
        UMask = "0007";
        EnvironmentFile = config.sops.secrets."hermes/env".path;
      };
      script = ''
        set -euo pipefail

        if [ ! -d "${research-profile-home}" ]; then
          ${lib.getExe hermes-package} profile create ${research-profile}
        fi

        touch "${research-profile-home}/.no-bundled-skills"
        chmod 0640 "${research-profile-home}/.no-bundled-skills"
        install -d -m 0750 "${research-profile-home}/skills/note-taking"

        if [ -e "${research-profile-home}/skills/note-taking/obsidian" ]; then
          chmod -R u+w "${research-profile-home}/skills/note-taking/obsidian" || true
          rm -rf "${research-profile-home}/skills/note-taking/obsidian"
        fi

        cp -r --no-preserve=mode "${bundled-obsidian-skill}" "${research-profile-home}/skills/note-taking/"
        chmod -R u+rwX "${research-profile-home}/skills/note-taking/obsidian"
        install -D -m 0640 ${research-profile-config} "${research-profile-home}/config.yaml"
      '';
    };

    systemd.services.hermes-dashboard = {
      after = [
        "hermes-agent.service"
        "hermes-research-profile.service"
      ];
      path = mcp-stdio-packages;
      wants = [
        "hermes-agent.service"
        "hermes-research-profile.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Hermes Agent Web Dashboard";
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        HERMES_DASHBOARD_PUBLIC_URL = "https://agent.spitz-pickerel.ts.net";
        OBSIDIAN_VAULT_PATH = research-obsidian-vault-path;
        CAMOFOX_URL = "http://127.0.0.1:9377";
        FIRECRAWL_API_URL = "http://127.0.0.1:3020";
      };
      serviceConfig = {
        Type = "simple";
        User = "hermes";
        EnvironmentFile = config.sops.secrets."hermes/env".path;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = "${lib.getExe hermes-package} -p ${research-profile} dashboard --host 0.0.0.0 --port ${toString dashboardPort} --no-open --skip-build";
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
      description = "Publish Hermes WebUI via Tailscale Serve";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:agent || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:agent --https=443 http://127.0.0.1:${toString dashboardProxyPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesHermesAgent = module;
    services = module;
  };
}
