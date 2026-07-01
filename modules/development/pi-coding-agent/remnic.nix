let
  remnicHost = "127.0.0.1";
  remnicPort = 4318;
  remnicPiInstall = pkgs:
    pkgs.writeShellApplication {
      name = "remnic-pi-install";
      runtimeInputs = [pkgs.python3];
      text = ''
              set -euo pipefail

              node_bin="${pkgs.nodejs}/bin/node"
              cli_path="$HOME/.pi/agent/npm/node_modules/@remnic/cli/bin/remnic.cjs"

              "$node_bin" "$cli_path" connectors install pi --config installExtension=false

              "${pkgs.python3}/bin/python3" - <<'PY'
        import json
        import pathlib
        import subprocess

        home = pathlib.Path.home()
        node_bin = pathlib.Path("${pkgs.nodejs}/bin/node")
        cli_path = home / ".pi/agent/npm/node_modules/@remnic/cli/bin/remnic.cjs"
        connector_path = home / ".config/engram/.engram-connectors/connectors/pi.json"
        output_dir = home / ".pi/agent/extensions/remnic"
        output_path = output_dir / "remnic.config.json"

        if not connector_path.exists():
            raise SystemExit(f"Missing Remnic Pi connector config: {connector_path}")

        connector_config = json.loads(connector_path.read_text())
        token_result = subprocess.run(
            [str(node_bin), str(cli_path), "token", "list", "--json"],
            capture_output=True,
            text=True,
            check=True,
        )
        token_entries = json.loads(token_result.stdout)
        auth_token = next(
            (
                entry.get("token")
                for entry in token_entries
                if entry.get("connector") == "pi" and entry.get("token")
            ),
            None,
        )

        if not auth_token:
            raise SystemExit("Missing Remnic Pi auth token; rerun `remnic token generate pi`.")

        config = {
            "remnicDaemonUrl": connector_config.get("remnicDaemonUrl") or "http://${remnicHost}:${toString remnicPort}",
            "authToken": auth_token,
            "recallMode": "auto",
            "recallTopK": 8,
            "recallBudgetChars": 12000,
            "recallEnabled": True,
            "observeEnabled": True,
            "compactionEnabled": True,
            "mcpToolsEnabled": True,
            "statusEnabled": True,
            "requestTimeoutMs": 60000,
            "startupRequestTimeoutMs": 1000,
        }

        namespace = connector_config.get("namespace")
        if isinstance(namespace, str) and namespace:
            config["namespace"] = namespace

        output_dir.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(config, indent=2) + "\n")
        output_path.chmod(0o600)

        for stale_name in ("index.ts", "README.md"):
            stale_path = output_dir / stale_name
            if stale_path.exists():
                stale_path.unlink()
        PY
      '';
    };

  module = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      programs.pi-coding-agent.settings.packages = [
        "npm:@remnic/cli"
        "npm:@remnic/plugin-pi"
      ];

      home.file.".config/remnic/config.json".text = builtins.toJSON {
        remnic = {
          memoryDir = "~/.local/share/remnic";
          identityContinuityEnabled = true;
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

      systemd.user.services.remnic-pi-install = {
        Unit = {
          Description = "Install Remnic Pi connector once";
          After = ["remnic.service"];
          Wants = ["remnic.service"];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${remnicPiInstall pkgs}/bin/remnic-pi-install";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = ["default.target"];
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
