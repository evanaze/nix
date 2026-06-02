{
  lib,
  pkgs,
  username,
  ...
}: let
  twentyPkg = pkgs.callPackage ../../pkgs/twenty {};
  twentyPort = 8081;
  caddyPort = 8082;
in {
  systemd.services.twenty = {
    after = [
      "network.target"
      "postgresql.service"
      "redis-twenty.service"
    ];
    wants = [
      "postgresql.service"
      "redis-twenty.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Twenty - CRM";
    path = [pkgs.gnused];
    environment = {};
    serviceConfig = {
      Type = "simple";
      User = username;
      WorkingDirectory = "/var/lib/twenty";
      StateDirectory = "twenty";
      ExecStart = lib.getExe twentyPkg;
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts.":${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString twentyPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };
  };

  services.postgres.ensureDatabases = ["twenty"];

  # Tailscale Serve publishes Twenty (via Caddy)
  systemd.services.twenty-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "caddy.service"
      "twenty.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "caddy.service"
      "twenty.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Twenty (via Caddy)";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:crm || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:crm --https=4440 http://127.0.0.1:${toString caddyPort}
    '';
  };
}
