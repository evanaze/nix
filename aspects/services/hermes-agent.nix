{
  inputs,
  lib,
  pkgs,
  config,
  username,
  ...
}: {
  # Apply upstream overlay, then patch the dashboard_auth missing subpackage
  nixpkgs.overlays = [
    inputs.hermes-agent.overlays.default
    (
      final: prev: let
        oldVenv = prev.hermes-agent.hermesVenv;

        # Build a new venv that copies the old one and adds dashboard_auth.
        # The upstream pyproject.toml is missing "hermes_cli.*" in
        # [tool.setuptools.packages.find].include, so uv2nix/setuptools
        # never discovers the dashboard_auth subpackage.
        # Tracked upstream: https://github.com/NousResearch/hermes-agent
        patchedVenv = final.runCommand "hermes-agent-env" {} ''
          # Copy the entire old venv, dereferencing symlinks (hermes_cli is a
          # symlink to another store path). Without -L, tar/chmod hit the
          # read-only target and fail with "Operation not permitted".
          mkdir -p $out
          (cd ${oldVenv} && tar chf - .) | (cd $out && tar xf -)
          chmod -R u+rwX $out

          # Fix all references to the old venv inside the new venv (shebangs,
          # config files, AND the ELF venv launcher binary all embed the old path)
          echo "hermes-agent: fixing shebangs in patched venv..."
          grep -rl "${oldVenv}" "$out" 2>/dev/null | while read -r f; do
            sed -i "s|${oldVenv}|$out|g" "$f"
            echo "  patched: $f"
          done

          # Add the missing dashboard_auth subpackage into site-packages
          SITE_PKG="$out/${final.python312.sitePackages}/hermes_cli"
          cp -r ${inputs.hermes-agent.outPath}/hermes_cli/dashboard_auth "$SITE_PKG/dashboard_auth"
          echo "hermes-agent: patched dashboard_auth into patched venv"
        '';
      in {
        hermes-agent = prev.hermes-agent.overrideAttrs (old: {
          installPhase =
            old.installPhase
            + ''
              # Replace all venv path references in the wrapper scripts to point
              # to the patched venv (which includes dashboard_auth).
              echo "hermes-agent: substituting venv refs: ${oldVenv} -> ${patchedVenv}"
              for f in "$out/bin/hermes" "$out/bin/.hermes-wrapped" \
                       "$out/bin/hermes-agent" "$out/bin/hermes-acp"; do
                if [ -f "$f" ]; then
                  # Use sed directly for precision — substituteInPlace just replaces strings
                  sed -i "s|${oldVenv}|${patchedVenv}|g" "$f"
                  echo "  patched: $f"
                fi
              done
            '';
        });
      }
    )
  ];

  # Shared Hermes HOME for both gateway/dashboard (hermes user) and CLI (evanaze)
  # This lets the dashboard see CLI sessions and vice versa.
  environment.variables = {
    HERMES_HOME = "/var/lib/hermes/.hermes";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hermes/.hermes 2770 hermes hermes -"
  ];

  users.users.${username}.extraGroups = ["hermes"];

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
