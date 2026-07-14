let
  airflowCompatOverlay = final: prev: {
    pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
      (_pyFinal: pyPrev: {
        wirerope = pyPrev.wirerope.overridePythonAttrs (old: {
          postPatch = (old.postPatch or "") + ''

            python - <<'PY'
            from pathlib import Path

            path = Path("setup.py")
            text = path.read_text()

            if "from pkg_resources import get_distribution" not in text:
                raise SystemExit("wirerope patch target import not found")

            if '    get_distribution("setuptools>=39.2.0")' not in text:
                raise SystemExit("wirerope patch target version check not found")

            text = text.replace("from pkg_resources import get_distribution\n", "", 1)
            text = text.replace('    get_distribution("setuptools>=39.2.0")', "    pass", 1)

            path.write_text(text)
            PY
          '';
        });
      })
    ];
  };

  module = {
    pkgs,
    lib,
    ...
  }: let
    airflowPort = 5512;
  in {
    nixpkgs.overlays = [airflowCompatOverlay];

    environment.systemPackages = [pkgs.apache-airflow];

    # systemd.services.airflow-db-init = {
    #   description = "Initialize Airflow PostgreSQL schema";
    #   after = [
    #     "postgresql-setup.service"
    #     "postgresql.service"
    #   ];
    #   requires = [
    #     "postgresql-setup.service"
    #     "postgresql.service"
    #   ];
    #   before = ["airflow.service"];
    #   path = with pkgs; [
    #     coreutils
    #     gnused
    #     postgresql
    #   ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #     User = "postgres";
    #     Group = "postgres";
    #     RemainAfterExit = true;
    #   };
    #   script = ''
    #     set -euo pipefail
    #   '';
    # };

    # systemd.services.airflow = {
    #   description = "Airflow self-hosted workflow orchestration";
    #   after = [
    #     "airflow-db-init.service"
    #     "network.target"
    #     "postgresql.service"
    #   ];
    #   requires = [
    #     "airflow-db-init.service"
    #     "postgresql.service"
    #   ];
    #   wantedBy = ["multi-user.target"];
    #   environment = {
    #   };
    #   serviceConfig = {
    #     Type = "simple";
    #     User = "airflow";
    #     Group = "airflow";
    #   };
    #   script = ''
    #     ${pkgs.apache-airflow}
    #   '';
    # };

    # systemd.services.airflow-tsserve = {
    #   after = [
    #     "tailscaled-autoconnect.service"
    #     "airflow.service"
    #   ];
    #   wants = [
    #     "tailscaled-autoconnect.service"
    #     "airflow.service"
    #   ];
    #   wantedBy = ["multi-user.target"];
    #   description = "Using Tailscale Serve to publish Airflow";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     Restart = "on-failure";
    #     RestartSec = "10s";
    #   };
    #   script = ''
    #     ${lib.getExe pkgs.tailscale} serve clear svc:jobs || true
    #     ${lib.getExe pkgs.tailscale} serve --service=svc:jobs --https=443 ${toString airflowPort}
    #   '';
    # };
  };
in {
  flake.modules.nixos = {
    # servicesAirflow = module;
    # services = module;
  };
}
