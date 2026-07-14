let
  module = {
    pkgs,
    lib,
    ...
  }: let
    airflowPort = 5512;
  in {
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
    servicesAirflow = module;
    services = module;
  };
}
