let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    falkordb = pkgs.callPackage ../../pkgs/falkordb {};
    falkordbPort = 6390;
    falkordbDir = "/mnt/eye/appdata/falkordb";
  in {
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
    };
  };
in {
  flake.modules.nixos = {
    servicesFalkordb = module;
    services = module;
  };
}
