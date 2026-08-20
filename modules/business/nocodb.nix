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

  services.tailscale.serve.services.nocodb.endpoints."tcp:443" = "http://127.0.0.1:${toString caddyPort}";
};
in {
  flake.modules.nixos = {
    businessNocodb = module;
    business = module;
  };
}
