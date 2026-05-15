{
  lib,
  config,
  pkgs,
  username,
  ...
}: let
  donetick-fe = pkgs.buildNpmPackage {
    pname = "donetick-frontend";
    version = "1.2.2";
    src = pkgs.fetchFromGitHub {
      owner = "donetick";
      repo = "frontend";
      rev = "develop";
      hash = lib.fakeHash;
    };
    npmDepsHash = lib.fakeHash;
    dontNpmBuild = true;
    buildPhase = ''
      runHook preBuild
      vite build --mode selfhosted
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/
      runHook postInstall
    '';
  };

  donetick = pkgs.buildGoModule rec {
    pname = "donetick";
    version = "0.1.75";
    src = pkgs.fetchFromGitHub {
      owner = "donetick";
      repo = "donetick";
      rev = "v${version}";
      hash = lib.fakeHash;
    };
    vendorHash = lib.fakeHash;
    preBuild = ''
      export CGO_ENABLED=0
      rm -rf frontend/dist
      cp -r ${donetick-fe}/dist frontend/dist
    '';
    ldflags = [
      "-X donetick.com/core/config.Version=${version}"
      "-X donetick.com/core/config.Commit=v${version}"
    ];
    meta = {
      mainProgram = "nix";
      platforms = lib.platforms.unix;
    };
  };
in {
  systemd.services.donetick = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "Donetick - Task and Chore management";
    path = [pkgs.gnused];
    environment = {
      DT_ENV = "selfhosted";
      DT_SQLITE_PATH = "/var/lib/donetick/donetick.db";
    };
    preStart = ''
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
          port: 2021
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
          max_connections: 1000
          max_connections_per_user: 5
          event_queue_size: 2048
          cleanup_interval: 2m
          stale_threshold: 5m
          enable_compression: true
          enable_stats: true
          allowed_origins:
            - "*"
      ''} > /var/lib/donetick/config/selfhosted.yaml
    '';
    serviceConfig = {
      Type = "simple";
      User = username;
      WorkingDirectory = "/var/lib/donetick";
      StateDirectory = "donetick";
      ExecStart = lib.getExe donetick;
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  sops.secrets.donetick-jwt = {};
}
