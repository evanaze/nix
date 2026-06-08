{
  inputs,
  lib,
  pkgs,
  config,
  username,
  ...
}: let
  state-dir = "/mnt/eye/appdata/hermes";
  hermes-home = "${state-dir}/.hermes";
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
        default = "gemma-4-12b-q4";
        provider = "local";
      };
      memory = {
        provider = "openviking";
      };
      providers = {
        local = {
          base_url = "https://llm.spitz-pickerel.ts.net:8724/v1";
          api_key = "none";
          model = "gemma-4-12b-q4";
          models = [
            "gemma-4-12b-q4"
            "qwen3.6-35b-a3b"
          ];
        };
      };
      platforms = {
        api_server = {
          enabled = true;
          extra = {
            key = "d156d12d681eb34356045688a43ba9487764e8731b946ce68d65aebb899324e6";
          };
        };
      };
    };
    mcpServers = {
      actual = {
        command = "npx";
        args = [
          "-y"
          "actual-mcp"
          "--enable-write"
        ];
        env = {
          ACTUAL_SERVER_URL = "https://budget.spitz-pickerel.ts.net:4432";
          ACTUAL_PASSWORD = "${config.sops.secrets.actual.path}";
        };
        timeout = 60;
        connect_timeout = 30;
      };
    };
    environmentFiles = [config.sops.secrets."hermes/env".path];
    addToSystemPackages = true;
  };

  sops.secrets."hermes/env" = {
    owner = "hermes";
    group = "hermes";
    mode = "0640";
  };

  systemd.services.hermes-dashboard = {
    after = ["hermes-agent.service"];
    wants = ["hermes-agent.service"];
    wantedBy = ["multi-user.target"];
    description = "Hermes Agent Web Dashboard";
    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    script = "${lib.getExe pkgs.hermes-agent} dashboard --host 0.0.0.0 --port 9119 --no-open --skip-build --insecure";
  };
}
