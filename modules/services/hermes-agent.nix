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
      "z ${hermes-home}/memories 2770 hermes hermes -"
      "d ${hermes-home}/skills 2770 hermes hermes -"
      "a+ /home/${username} - - - - u:hermes:--x,m::--x"
      "a+ /home/${username}/.config - - - - u:hermes:--x,m::--x"

      "A+ /home/${username}/.config/nix - - - - u:hermes:rwX"
      "A+ /home/${username}/workspace - - - - u:hermes:rwX"

      "A+ /home/${username}/.config/nix - - - - d:u:hermes:rwX"
      "A+ /home/${username}/workspace - - - - d:u:hermes:rwX"
    ];

    users.users.${username}.extraGroups = ["hermes"];

    environment.systemPackages = with pkgs; [
      hermes-agent
    ];

    services.hermes-agent = {
      enable = true;
      createUser = true;
      stateDir = "${state-dir}";
      settings = {
        model = {
          default = "gpt-5.5";
          provider = "openai-codex";
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
        };
        plugins.enabled = [
          "disk-cleanup"
          "ntfy-platform"
          "web-searxng"
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
              "gemma-4-12b-q4"
              "qwen3.6-35b-a3b"
            ];
          };
        };
        platforms.api_server.enabled = true;
      };
      mcpServers = {
        actual = {
          command = "export ACTUAL_PASSWORD=$(cat ${config.sops.secrets.actual.path}) npx";
          args = [
            "-y"
            "actual-mcp"
            "--enable-write"
          ];
          env = {
            ACTUAL_SERVER_URL = "https://budget.spitz-pickerel.ts.net";
          };
          timeout = 60;
          connect_timeout = 30;
        };
      };
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        MESSAGING_CWD = "${state-dir}/workspace";
        CAMOFOX_URL = "http://127.0.0.1:9377";
        SEARXNG_URL = "http://127.0.0.1:8311";
      };
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
    };

    sops.secrets."hermes/env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0640";
    };

    systemd.services.hermes-agent = {
      after = ["camofox.service"];
      wants = ["camofox.service"];
    };

    systemd.services.hermes-dashboard = {
      after = ["hermes-agent.service"];
      wants = ["hermes-agent.service"];
      wantedBy = ["multi-user.target"];
      description = "Hermes Agent Web Dashboard";
      environment = {
        HOME = state-dir;
        HERMES_HOME = hermes-home;
        HERMES_MANAGED = "true";
        HERMES_DASHBOARD_PUBLIC_URL = "https://agent.spitz-pickerel.ts.net";
        CAMOFOX_URL = "http://127.0.0.1:9377";
        SEARXNG_URL = "http://127.0.0.1:8311";
      };
      serviceConfig = {
        Type = "simple";
        User = "hermes";
        EnvironmentFile = config.sops.secrets."hermes/env".path;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = "${lib.getExe pkgs.hermes-agent} dashboard --host 0.0.0.0 --port ${toString dashboardPort} --no-open --skip-build";
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
