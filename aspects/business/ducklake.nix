{
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets."ducklake/db-password" = {
    owner = "postgres";
    group = "postgres";
    mode = "0640";
  };

  environment.systemPackages = with pkgs; [
    duckdb
  ];

  systemd.tmpfiles.rules = [
    "d /storage/data/ducklake 0755 root root -"
  ];

  systemd.services.ducklake-db-init = {
    after = ["postgresql.service" "sops-secrets.target"];
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

  services.postgresql = {
    ensureDatabases = ["ducklake" "ducklake_catalog"];
    ensureUsers = [
      {
        name = "ducklake";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
    authentication = lib.mkAfter ''
      host ducklake_catalog ducklake 100.64.0.0/10 scram-sha-256
      host ducklake_catalog ducklake fd7a:115c:a1e0::/48 scram-sha-256
    '';
  };
}