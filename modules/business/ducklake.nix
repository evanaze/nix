let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: {
    sops.secrets = {
      "ducklake/db-password" = {
        owner = "postgres";
        group = "postgres";
        mode = "0640";
      };
    };

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

    services.postgresql = {
      ensureDatabases = [
        "ducklake"
        "ducklake_catalog"
      ];
      ensureUsers = [
        {
          name = "ducklake";
          ensureDBOwnership = true;
          ensureClauses = {
            login = true;
          };
        }
      ];
      authentication = lib.mkOverride 10 (lib.mkAfter ''
        # Tailscale Serve forwards svc:pg to PostgreSQL over loopback.
        host ducklake_catalog ducklake 127.0.0.1/32 scram-sha-256
        host ducklake_catalog ducklake ::1/128 scram-sha-256
      '');
    };
  };
in {
  flake.modules.nixos = {
    businessDucklake = module;
    business = module;
  };
}
