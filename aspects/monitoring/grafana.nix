# aspects/monitoring/grafana.nix - Grafana dashboards
{
  lib,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 2342;
        http_addr = "127.0.0.1";
        domain = "monitoring.spitz-pickerel.ts.net";
      };
      security.secret_key = "/run/secrets/grafana";
    };

    provision = {
      datasources.settings.datasources = {
        name = "Prometheus";
        url = "http://localhost:9001";
      };
    };
  };

  systemd.services.grafana-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "grafana.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "grafana.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Grafana";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:monitoring --https=4431 http://127.0.0.1:2342";
  };
}
