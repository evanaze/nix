let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.falkordb;
    falkordb = pkgs.callPackage ../../pkgs/falkordb {};
    falkordbPort = 6390;
    falkordbDir = "/mnt/eye/appdata/falkordb";
  in {
    options.services.falkordb.browser = {
      enable = lib.mkEnableOption "FalkorDB browser web UI";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Port for the FalkorDB browser to listen on.";
      };
      password = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "Password for the FalkorDB browser (sets FALKORDB_PASSWORD env).";
      };
    };

    config = lib.mkIf (config.networking.hostName == "jupiter") {
      services.redis.servers.falkordb = {
        enable = true;
        port = falkordbPort;
        bind = "127.0.0.1";
        save = [[900 1] [300 10] [60 10000]];
        maxclients = 10000;
        settings = {
          loadmodule = ["${falkordb}/lib/falkordb.so"];
          timeout = "0";
          dir = lib.mkForce falkordbDir;
        };
      };

      systemd.services.redis-falkordb = {
        after = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        requires = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        preStart = ''
          mkdir -p ${falkordbDir}
          chmod 0750 ${falkordbDir}
        '';
        serviceConfig.StateDirectory = "redis-falkordb";
        serviceConfig.SystemCallFilter = lib.mkForce "";
        serviceConfig.ReadWritePaths = [falkordbDir];
      };

      systemd.services.falkordb-tsserve = {
        after = [
          "tailscaled-autoconnect.service"
          "redis-falkordb.service"
        ];
        wants = [
          "tailscaled-autoconnect.service"
          "redis-falkordb.service"
        ];
        wantedBy = ["multi-user.target"];
        description = "Using Tailscale Serve to publish FalkorDB";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";
        };
        script = ''
          ${lib.getExe pkgs.tailscale} serve --service=svc:falkordb --https=443 falkordbPort
        '';
      };
      systemd.services.falkordb-browser = lib.mkIf cfg.browser.enable {
        description = "FalkorDB Browser Web UI";
        after = [
          "network.target"
          "redis-falkordb.service"
        ];
        requires = ["redis-falkordb.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = "${lib.getExe' falkordb "falkordb-browser"}";
          Restart = "on-failure";
          RestartSec = "10s";
          Environment = [
            "PORT=${toString cfg.browser.port}"
            "REDIS_URL=redis://127.0.0.1:${toString falkordbPort}"
          ] ++ lib.optionals (cfg.browser.password != null) [
            "FALKORDB_PASSWORD=${cfg.browser.password}"
          ];
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesFalkordb = module;
    services = module;
  };
}
