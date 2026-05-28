{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  # Apply upstream overlay, then patch the dashboard_auth missing subpackage
  nixpkgs.overlays = [
    inputs.hermes-agent.overlays.default
    (final: prev: {
      hermes-agent = prev.hermes-agent.overrideAttrs (old: {
        installPhase = old.installPhase + ''
          # HACK: upstream pyproject.toml missing "hermes_cli.*" in
          # [tool.setuptools.packages.find].include, so uv2nix/setuptools
          # never discovers the hermes_cli/dashboard_auth subpackage.
          # web_server.py then fails at line 4822 on import.
          # Tracked upstream: https://github.com/NousResearch/hermes-agent
          AUTH_DIR="$out/${final.python312.sitePackages}/hermes_cli/dashboard_auth"
          mkdir -p "$(dirname "$AUTH_DIR")"
          cp -r "${inputs.hermes-agent.outPath}/hermes_cli/dashboard_auth" "$AUTH_DIR"
          chmod -R +w "$AUTH_DIR"
          echo "hermes-agent: patched dashboard_auth subpackage"

          # Extend PYTHONPATH on all wrapped binaries so the module resolves
          for bin in hermes hermes-agent hermes-acp; do
            if [ -f "$out/bin/$bin" ]; then
              wrapProgram "$out/bin/$bin" \
                --suffix PYTHONPATH : "$out/${final.python312.sitePackages}"
            fi
          done
        '';
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    hermes-agent
  ];

  services.hermes-agent = {
    enable = true;
    # documents = ["$HOME/.config/nix"];
    settings = {
      model.default = "deepseek/deepseek-v4-flash";
      memory = {
        provider = "openviking";
      };
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
    };
  };

  sops.secrets."hermes/env" = {
    owner = "hermes";
  };

  systemd.services.hermes-dashboard = {
    after = [
      "network-online.target"
      "hermes-agent.service"
    ];
    wants = ["hermes-agent.service"];
    wantedBy = ["multi-user.target"];
    description = "Hermes Agent Web Dashboard";
    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    script = "${lib.getExe pkgs.hermes-agent} dashboard --host 0.0.0.0 --port 9119 --tui --no-open --skip-build --insecure";
  };

  systemd.services.hermes-tsserve = {
    after = [
      "tailscaled.service"
      "hermes-dashboard.service"
    ];
    wants = [
      "tailscaled.service"
      "hermes-dashboard.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Hermes Agent Dashboard";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:agent --https=4430 9119";
  };
}
