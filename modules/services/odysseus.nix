let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    odysseus = pkgs.callPackage ../../pkgs/odysseus {};

    odysseusPort = 7000;
    odysseusCaddyPort = 7001;
    chromadbPort = 8100;
    searxngPort = 8311;

    appDir = "/mnt/eye/appdata/odysseus";
    dataDir = "${appDir}/data";
    chromadbDir = "/mnt/eye/appdata/chromadb";
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      users.groups.odysseus = {};
      users.users.odysseus = {
        isSystemUser = true;
        group = "odysseus";
        home = appDir;
      };

      environment.systemPackages = [odysseus];

      services.chromadb = {
        enable = true;
        host = "127.0.0.1";
        port = chromadbPort;
        dbpath = chromadbDir;
        openFirewall = false;
      };

      systemd.services.chromadb = {
        after = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        requires = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        environment.ANONYMIZED_TELEMETRY = "FALSE";
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "odysseus";
          Group = "odysseus";
          WorkingDirectory = lib.mkForce chromadbDir;
          ReadWritePaths = [chromadbDir];
        };
      };

      systemd.services.odysseus = {
        description = "Odysseus self-hosted AI workspace";
        after = [
          "network.target"
          "create-appdata-datasets.service"
          "zfs-mount.service"
          "chromadb.service"
          "searx.service"
        ];
        requires = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
          "chromadb.service"
        ];
        wants = ["searx.service"];
        wantedBy = ["multi-user.target"];
        path = with pkgs; [
          bash
          coreutils
          curl
          git
          nodejs
          openssh
          tmux
        ];
        environment = {
          APP_PORT = toString odysseusPort;
          AUTH_ENABLED = "true";
          CHROMADB_HOST = "127.0.0.1";
          CHROMADB_PORT = toString chromadbPort;
          DATABASE_URL = "sqlite:////mnt/eye/appdata/odysseus/data/app.db";
          FASTEMBED_CACHE_PATH = "${dataDir}/fastembed_cache";
          HOME = "${appDir}/home";
          LOCALHOST_BYPASS = "false";
          ODYSSEUS_DATA_DIR = dataDir;
          ODYSSEUS_INTERNAL_BASE = "http://127.0.0.1:${toString odysseusPort}";
          ODYSSEUS_MAIL_ATTACHMENTS_DIR = "${dataDir}/mail-attachments";
          ODYSSEUS_SKIP_ADMIN_PROMPT = "1";
          ODYSSEUS_SKIP_RUN_HINT = "1";
          SEARXNG_INSTANCE = "http://127.0.0.1:${toString searxngPort}";
          SECURE_COOKIES = "true";
          XDG_CACHE_HOME = "${appDir}/cache";
        };
        preStart = ''
          mkdir -p \
            ${dataDir}/logs \
            ${dataDir}/fastembed_cache \
            ${dataDir}/mail-attachments \
            ${appDir}/cache \
            ${appDir}/home/.cache/huggingface \
            ${appDir}/home/.local \
            ${appDir}/home/.ssh
        '';
        serviceConfig = {
          Type = "simple";
          User = "odysseus";
          Group = "odysseus";
          WorkingDirectory = appDir;
          ExecStart = "${lib.getExe odysseus} --host 127.0.0.1 --port ${toString odysseusPort}";
          Restart = "on-failure";
          RestartSec = "10s";
          ReadWritePaths = [appDir];
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts."http://:${toString odysseusCaddyPort}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:${toString odysseusPort} {
              header_up X-Forwarded-Proto https
              header_up X-Forwarded-For {remote_host}
              header_up X-Forwarded-Host {host}
            }
          '';
        };
      };

      systemd.services.odysseus-tsserve = {
        after = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "caddy.service"
          "odysseus.service"
        ];
        wants = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "caddy.service"
          "odysseus.service"
        ];
        wantedBy = ["multi-user.target"];
        description = "Using Tailscale Serve to publish Odysseus";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";
        };
        script = ''
          ${lib.getExe pkgs.tailscale} serve clear svc:odysseus || true
          ${lib.getExe pkgs.tailscale} serve --service=svc:odysseus --https=443 http://127.0.0.1:${toString odysseusCaddyPort}
        '';
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesOdysseus = module;
    services = module;
  };
}
