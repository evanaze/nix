let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    firecrawl = pkgs.callPackage ../../pkgs/firecrawl {};
    firecrawlSrc = firecrawl.src;
    firecrawlRev = firecrawl.rev;
    prepareStamp = "8";

    appDir = "/var/lib/firecrawl";
    releaseDir = "${appDir}/releases/${firecrawlRev}";
    apiDir = "${releaseDir}/apps/api";
    dataDir = "/mnt/eye/appdata/firecrawl";

    firecrawlPort = 3002;
    caddyPort = 3020;
    databaseName = "firecrawl_nuq";

    nodejs = pkgs.nodejs_22;
    pnpm = pkgs.pnpm;
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      users.groups.firecrawl = {};
      users.users.firecrawl = {
        isSystemUser = true;
        group = "firecrawl";
        home = appDir;
      };

      services.rabbitmq = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 5672;
        managementPlugin.enable = false;
      };

      services.postgresql = {
        ensureDatabases = [databaseName];
        extensions = ps: [ps.pg_cron];
        settings = {
          shared_preload_libraries = "pg_cron";
          "cron.database_name" = databaseName;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${dataDir} 0750 firecrawl firecrawl -"
      ];

      systemd.services.firecrawl-prepare = {
        description = "Prepare pinned Firecrawl checkout";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        path = with pkgs; [
          bash
          cargo
          cmake
          coreutils
          findutils
          gcc
          git
          go
          gnumake
          gnused
          nodejs
          openssl
          pkg-config
          pnpm
          postgresql
          prelink
          python3
          rustc
          which
        ];
        environment = {
          CARGO_HOME = "${appDir}/cargo";
          GOCACHE = "${appDir}/cache/go-build";
          GOMODCACHE = "${appDir}/go/pkg/mod";
          HOME = "${appDir}/home";
          HUSKY = "0";
          npm_config_cache = "${appDir}/cache/npm";
          npm_config_nodedir = "${lib.getDev nodejs}";
          npm_config_node_gyp = "${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js";
          npm_config_python = lib.getExe pkgs.python3;
          PNPM_HOME = "${appDir}/pnpm";
          PYTHON = lib.getExe pkgs.python3;
          XDG_CACHE_HOME = "${appDir}/cache";
        };
        serviceConfig = {
          Type = "oneshot";
          User = "firecrawl";
          Group = "firecrawl";
          StateDirectory = "firecrawl";
          ReadWritePaths = [appDir];
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail

          if [ -f ${releaseDir}/.built-ok-${prepareStamp} ]; then
            exit 0
          fi

          mkdir -p \
            ${appDir}/releases \
            ${appDir}/cache \
            ${appDir}/cargo \
            ${appDir}/go/pkg/mod \
            ${appDir}/home \
            ${appDir}/pnpm

          release_tmp=${releaseDir}.tmp
          rm -rf "$release_tmp"
          mkdir -p "$release_tmp"
          cp -R ${firecrawlSrc}/. "$release_tmp/"
          chmod -R u+w "$release_tmp"

          cd "$release_tmp/apps/api"
          pnpm install --frozen-lockfile

          koffi_dir=$(find node_modules/.pnpm -path '*/node_modules/koffi' -type d -print -quit)
          if [ -n "$koffi_dir" ]; then
            koffi_dir=$(readlink -f "$koffi_dir")
          fi
          if [ -n "$koffi_dir" ] && [ -d "$koffi_dir/build/koffi" ]; then
            mkdir -p "$koffi_dir/../build"
            ln -sfn ../koffi/build/koffi "$koffi_dir/../build/koffi"

            find "$koffi_dir/build/koffi" \
              -path '*/linux_x64/*.node' \
              -type f \
              -print0 \
              | while IFS= read -r -d "" addon; do
                execstack -c "$addon"
                execstack -q "$addon"
              done
          fi

          cd sharedLibs/go-html-to-md
          go mod download
          go build -o libhtml-to-markdown.so -buildmode=c-shared html-to-markdown.go

          cd "$release_tmp/apps/api"
          pnpm build

          touch "$release_tmp/.built-ok-${prepareStamp}"
          rm -rf ${releaseDir}
          mv "$release_tmp" ${releaseDir}
        '';
      };

      systemd.services.firecrawl-db-init = {
        description = "Initialize Firecrawl NuQ PostgreSQL schema";
        after = [
          "postgresql-setup.service"
          "postgresql.service"
        ];
        requires = [
          "postgresql-setup.service"
          "postgresql.service"
        ];
        before = ["firecrawl.service"];
        path = with pkgs; [
          coreutils
          gnused
          postgresql
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          Group = "postgres";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail

          stamp=/var/lib/postgresql/.firecrawl-nuq-schema-${firecrawlRev}
          if [ -f "$stamp" ] && [ "$(psql -Atqc "SELECT to_regclass('nuq.queue_crawl_finished') IS NOT NULL" ${databaseName})" = "t" ]; then
            exit 0
          fi

          psql -v ON_ERROR_STOP=1 -d ${databaseName} -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS pg_cron;'

          # Keep Firecrawl's schema and cron jobs, but do not let it mutate
          # global PostgreSQL tuning on this shared existing database service.
          sed -E '/^ALTER SYSTEM SET /d;/^SELECT pg_reload_conf\(\);/d' \
            ${firecrawlSrc}/apps/nuq-postgres/nuq.sql \
            > /tmp/firecrawl-nuq.sql

          psql -v ON_ERROR_STOP=1 -d ${databaseName} -f /tmp/firecrawl-nuq.sql
          touch "$stamp"
        '';
      };

      systemd.services.firecrawl = {
        description = "Firecrawl self-hosted scraping API";
        after = [
          "firecrawl-db-init.service"
          "firecrawl-prepare.service"
          "network.target"
          "postgresql.service"
          "rabbitmq.service"
          "redis-twenty.service"
        ];
        requires = [
          "firecrawl-db-init.service"
          "firecrawl-prepare.service"
          "postgresql.service"
          "rabbitmq.service"
          "redis-twenty.service"
        ];
        wantedBy = ["multi-user.target"];
        path = [
          pkgs.bash
          nodejs
          pnpm
          pkgs.coreutils
          pkgs.gcc
          pkgs.git
          pkgs.go
          pkgs.gnumake
        ];
        environment = {
          BULL_AUTH_KEY = "@";
          CARGO_HOME = "${appDir}/cargo";
          CI = "true";
          FIRECRAWL_APP_HOST = "127.0.0.1";
          FIRECRAWL_APP_PORT = toString firecrawlPort;
          FIRECRAWL_APP_SCHEME = "http";
          GOCACHE = "${appDir}/cache/go-build";
          GOMODCACHE = "${appDir}/go/pkg/mod";
          HOME = "${appDir}/home";
          HOST = "127.0.0.1";
          NODE_ENV = "production";
          NUQ_DATABASE_URL = "postgresql://postgres@127.0.0.1:5432/${databaseName}";
          NUQ_DATABASE_URL_LISTEN = "postgresql://postgres@127.0.0.1:5432/${databaseName}";
          NUQ_RABBITMQ_URL = "amqp://guest:guest@127.0.0.1:5672";
          PNPM_HOME = "${appDir}/pnpm";
          PORT = toString firecrawlPort;
          REDIS_RATE_LIMIT_URL = "redis://127.0.0.1:6379/2";
          REDIS_URL = "redis://127.0.0.1:6379/1";
          USE_DB_AUTHENTICATION = "false";
        };
        serviceConfig = {
          Type = "simple";
          User = "firecrawl";
          Group = "firecrawl";
          WorkingDirectory = apiDir;
          ExecStart = "${lib.getExe nodejs} dist/src/harness.js --start-docker";
          Restart = "on-failure";
          RestartSec = "10s";
          StateDirectory = "firecrawl";
          ReadWritePaths = [
            appDir
            dataDir
          ];
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts."http://:${toString caddyPort}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:${toString firecrawlPort} {
              header_up X-Forwarded-Proto https
              header_up X-Forwarded-For {remote_host}
              header_up X-Forwarded-Host {host}
            }
          '';
        };
      };

    };
  };
in {
  flake.modules.nixos = {
    servicesFirecrawl = module;
    services = module;
  };
}
