let
  module = {
    pkgs,
    lib,
    ...
  }: let
    airflowPort = 5512;
    caddyPort = 5513;
    databaseName = "airflow";
    airflowUser = "airflow";
    airflowHome = "/var/lib/airflow";
    airflowEnvFile = "${airflowHome}/airflow.env";
    airflowExe = lib.getExe pkgs.apache-airflow;

    airflowEnvironment = {
      AIRFLOW_HOME = airflowHome;
      AIRFLOW__API__BASE_URL = "http://127.0.0.1:${toString caddyPort}";
      AIRFLOW__CORE__DAGS_FOLDER = "${airflowHome}/dags";
      AIRFLOW__CORE__EXECUTION_API_SERVER_URL = "http://127.0.0.1:${toString airflowPort}/execution/";
      AIRFLOW__CORE__EXECUTOR = "LocalExecutor";
      AIRFLOW__CORE__LOAD_EXAMPLES = "False";
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN = "postgresql+psycopg2://${airflowUser}@/${databaseName}?host=/run/postgresql";
      AIRFLOW__SCHEDULER__ENABLE_HEALTH_CHECK = "True";
    };

    mkAirflowService = {
      name,
      command,
      after ? [],
    }: {
      description = name;
      after =
        [
          "airflow-db-init.service"
          "network.target"
          "postgresql.service"
        ]
        ++ after;
      requires = [
        "airflow-db-init.service"
        "postgresql.service"
      ];
      wantedBy = ["multi-user.target"];
      environment = airflowEnvironment;
      serviceConfig = {
        Type = "simple";
        User = airflowUser;
        Group = airflowUser;
        WorkingDirectory = airflowHome;
        StateDirectory = "airflow";
        EnvironmentFile = airflowEnvFile;
        ExecStart = "${airflowExe} ${command}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  in {
    users.groups.airflow = {};
    users.users.airflow = {
      isSystemUser = true;
      group = airflowUser;
      home = airflowHome;
    };

    services.postgresql.ensureDatabases = [databaseName];
    services.postgresql.ensureUsers = [
      {
        name = airflowUser;
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${airflowHome}/dags 0750 ${airflowUser} ${airflowUser} -"
      "d ${airflowHome}/logs 0750 ${airflowUser} ${airflowUser} -"
    ];

    systemd.services.airflow-db-init = {
      description = "Initialize Airflow PostgreSQL schema";
      after = [
        "postgresql-setup.service"
        "postgresql.service"
      ];
      requires = [
        "postgresql-setup.service"
        "postgresql.service"
      ];
      before = [
        "airflow-api.service"
        "airflow-scheduler.service"
        "airflow-dag-processor.service"
        "airflow-triggerer.service"
      ];
      path = with pkgs; [
        coreutils
        openssl
      ];
      environment = airflowEnvironment;
      serviceConfig = {
        Type = "oneshot";
        User = airflowUser;
        Group = airflowUser;
        WorkingDirectory = airflowHome;
        StateDirectory = "airflow";
        RemainAfterExit = true;
      };
      script = ''
                set -euo pipefail

                mkdir -p ${airflowHome}/dags ${airflowHome}/logs

                if [ ! -f ${airflowEnvFile} ]; then
                  umask 0077
                  secret_key="$(${lib.getExe pkgs.openssl} rand -hex 32)"
                  cat > ${airflowEnvFile} <<EOF
        AIRFLOW__API__SECRET_KEY=$secret_key
        EOF
                  chmod 0640 ${airflowEnvFile}
                fi

                ${airflowExe} db migrate
      '';
    };

    systemd.services.airflow-api = mkAirflowService {
      name = "Airflow API server";
      command = "api-server --host 127.0.0.1 --port ${toString airflowPort}";
    };

    systemd.services.airflow-scheduler = mkAirflowService {
      name = "Airflow scheduler";
      command = "scheduler";
    };

    systemd.services.airflow-dag-processor = mkAirflowService {
      name = "Airflow DAG processor";
      command = "dag-processor";
    };

    systemd.services.airflow-triggerer = mkAirflowService {
      name = "Airflow triggerer";
      command = "triggerer";
    };

    services.caddy.virtualHosts."http://127.0.0.1:${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString airflowPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    systemd.services.airflow-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "caddy.service"
        "airflow-api.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "caddy.service"
        "airflow-api.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Airflow";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:jobs || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:jobs --https=443 http://127.0.0.1:${toString caddyPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesAirflow = module;
    services = module;
  };
}
