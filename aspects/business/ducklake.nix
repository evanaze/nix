{
  config,
  lib,
  pkgs,
  ...
}: let
  duckdbUser = "duckdb";
  dataDir = "/mnt/eye/appdata/ducklake";
  dbFile = "${dataDir}/ducklake.db";
  duckDbPort = 4213;
  caddyPort = 4214;
in {
  sops.secrets = {
    "ducklake/db-password" = {
      owner = "postgres";
      group = "postgres";
      mode = "0640";
    };
    "ducklake/quack-token" = {
      owner = duckdbUser;
      group = duckdbUser;
      mode = "0400";
    };
  };

  users.users.${duckdbUser} = {
    isSystemUser = true;
    group = duckdbUser;
    home = dataDir;
    createHome = true;
  };
  users.groups.${duckdbUser} = {};

  environment.systemPackages = with pkgs; [
    duckdb
  ];

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${duckdbUser} ${duckdbUser} -"
  ];

  systemd.services.ducklake-db-init = {
    after = [
      "postgresql.service"
      "sops-secrets.target"
    ];
    requires = ["postgresql.service"];
    wantedBy = ["multi-user.target"];
    description = "Set DuckLake PostgreSQL user password";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = ''
      PSQL="${lib.getExe' pkgs.postgresql_18 "psql"}"
      PASSWORD="$(cat ${config.sops.secrets."ducklake/db-password".path})"
      "$PSQL" -c "ALTER ROLE ducklake PASSWORD '$PASSWORD';"
    '';
  };

  systemd.services.duckdb-server = {
    description = "DuckDB Quack Server with Web UI";
    after = [
      "postgresql.service"
      "sops-secrets.target"
      "zfs-mount.service"
    ];
    wants = ["postgresql.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = duckdbUser;
      Group = duckdbUser;
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = dataDir;
    };
    environment = {
      NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = ''
            TOKEN="$(cat ${config.sops.secrets."ducklake/quack-token".path})"
            INIT_FILE="$(mktemp)"
            cat > "$INIT_FILE" << EOF
      INSTALL quack FROM core_nightly;
      LOAD quack;
      INSTALL ui;
      LOAD ui;
      CALL quack_serve('quack:localhost:9494', token = '$TOKEN');
      CALL start_ui_server();
      EOF
            ${lib.getExe pkgs.duckdb} "${dbFile}" -init "$INIT_FILE" < <(exec sleep infinity)
    '';
  };

  services.caddy.virtualHosts."http://:${toString caddyPort}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString duckDbPort} {
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Host {host}
      }
    '';
  };

  # systemd.services.duckdb-tsserve = {
  #   after = [
  #     "tailscaled.service"
  #     "duckdb-server.service"
  #   ];
  #   wants = [
  #     "tailscaled.service"
  #     "duckdb-server.service"
  #   ];
  #   wantedBy = ["multi-user.target"];
  #   description = "Expose DuckDB UI via Tailscale Serve";
  #   serviceConfig = {
  #     Type = "simple";
  #     RemainAfterExit = true;
  #   };
  #   script = "${lib.getExe pkgs.tailscale} serve --service=svc:dwh --https=4439 http://127.0.0.1:${toString caddyPort}";
  # };

  # services.postgresql = {
  #   ensureDatabases = [
  #     "ducklake"
  #     "ducklake_catalog"
  #   ];
  #   ensureUsers = [
  #     {
  #       name = "ducklake";
  #       ensureDBOwnership = true;
  #       ensureClauses = {
  #         login = true;
  #       };
  #     }
  #   ];
  #   authentication = lib.mkAfter ''
  #     host ducklake_catalog ducklake 100.64.0.0/10 scram-sha-256
  #     host ducklake_catalog ducklake fd7a:115c:a1e0::/48 scram-sha-256
  #   '';
  # };
}
