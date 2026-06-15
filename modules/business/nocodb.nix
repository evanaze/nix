let
  module = # aspects/business/nocodb.nix - NocoDB (via Docker, as recommended upstream)
{
  lib,
  pkgs,
  ...
}: let
  nocodbPort = 8082;
  caddyPort = 8083;
  redisPort = 6380;
  tsServePort = 4432;
in {
  services.caddy = {
    enable = true;
    virtualHosts.":${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString nocodbPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.nocodb = {
      image = "nocodb/nocodb:latest";
      autoStart = true;
      extraOptions = ["--network=host"];
      environment = {
        NC_DB = "pg://127.0.0.1:5432?u=postgres&d=nocodb";
        NC_REDIS_URL = "redis://127.0.0.1:${toString redisPort}";
        PORT = toString nocodbPort;
      };
    };
  };

  systemd.services.docker-nocodb = {
    after = [
      "postgresql.service"
      "redis-nocodb.service"
    ];
    requires = [
      "postgresql.service"
      "redis-nocodb.service"
    ];
  };

  services.postgresql = {
    ensureDatabases = ["nocodb"];
  };

  services.redis.servers.nocodb = {
    enable = true;
    port = redisPort;
  };

  systemd.services.nocodb-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "caddy.service"
      "docker-nocodb.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "caddy.service"
      "docker-nocodb.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Publish NocoDB via Tailscale Serve";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:nocodb || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:nocodb --https=${toString tsServePort} http://127.0.0.1:${toString caddyPort}
    '';
  };
};
in {
  flake.modules.nixos = {
    businessNocodb = module;
    business = module;
  };
}
