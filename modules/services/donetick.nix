let
  module = {
    lib,
    config,
    pkgs,
    username,
    ...
  }: let
    version = "0.1.75";
    donetick = pkgs.stdenv.mkDerivation {
      pname = "donetick";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://github.com/donetick/donetick/releases/download/v${version}/donetick_Linux_x86_64.tar.gz";
        hash = "sha256-uCWAeLGxeR6+rrUSQATdFWsA78V69KLb6u3iRGMSnso=";
      };
      sourceRoot = ".";
      installPhase = ''
        mkdir -p $out/bin
        install -m 755 donetick $out/bin/
      '';
      meta = {
        mainProgram = "donetick";
        platforms = lib.platforms.linux;
      };
    };

    donetickPort = 2021;
    caddyPort = 2022;
  in {
    systemd.services.donetick = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "Donetick - Task and Chore management";
      path = [pkgs.gnused];
      environment = {
        DT_ENV = "selfhosted";
        DT_SQLITE_PATH = "/mnt/eye/appdata/donetick/donetick.db";
      };
      preStart = ''
        mkdir -p /mnt/eye/appdata/donetick/config
        sed "s/JWT_SECRET_PLACEHOLDER/$(cat ${config.sops.secrets.donetick-jwt.path})/" \
          ${pkgs.writeText "selfhosted.yaml" ''
          name: "selfhosted"
          is_done_tick_dot_com: false
          is_user_creation_disabled: false
          database:
            type: "sqlite"
            migration: true
          jwt:
            secret: "JWT_SECRET_PLACEHOLDER"
            session_time: 168h
            max_refresh: 1440h
          server:
            port: ${toString donetickPort}
            read_timeout: 10s
            write_timeout: 10s
            rate_period: 60s
            rate_limit: 300
            cors_allow_origins:
              - "http://localhost:5173"
              - "http://localhost:7926"
              - "https://localhost"
              - "http://localhost"
              - "capacitor://localhost"
            serve_frontend: true
            serve_swagger: true
            public_host: ""
          logging:
            level: "info"
            encoding: "json"
            development: false
          scheduler_jobs:
            due_job: 30m
            overdue_job: 3h
            pre_due_job: 3h
          realtime:
            enabled: true
            sse_enabled: true
            heartbeat_interval: 60s
            connection_timeout: 120s
            max_connections: 1001
            max_connections_per_user: 5
            event_queue_size: 2048
            cleanup_interval: 2m
            stale_threshold: 5m
            enable_compression: true
            enable_stats: true
            allowed_origins:
              - "*"
        ''} > /mnt/eye/appdata/donetick/config/selfhosted.yaml
      '';
      serviceConfig = {
        Type = "simple";
        User = username;
        WorkingDirectory = "/mnt/eye/appdata/donetick";
        StateDirectory = "donetick";
        ExecStart = lib.getExe donetick;
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    sops.secrets.donetick-jwt = {
      owner = username;
    };

    services.caddy.virtualHosts."http://:${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString donetickPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    # Tailscale Serve now points to Caddy instead of Donetick directly
    systemd.services.donetick-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "caddy.service"
        "donetick.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "caddy.service"
        "donetick.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Donetick (via Caddy)";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:todo || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:todo --https=443 http://127.0.0.1:${toString caddyPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesDonetick = module;
    services = module;
  };
}
