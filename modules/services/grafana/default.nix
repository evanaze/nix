let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.grafana = {
      enable = true;
      dataDir = "/mnt/eye/appdata/grafana";
      settings = {
        server = {
          http_port = 2342;
          http_addr = "127.0.0.1";
          domain = "monitoring.spitz-pickerel.ts.net";
        };
        security.secret_key = "/run/secrets/grafana";
      };

      provision.datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString config.services.prometheus.port}";
        }
      ];
    };

    services.tailscale.serve.services.monitoring.endpoints."tcp:443" = "http://127.0.0.1:2342";
  };
in {
  flake.modules.nixos = {
    servicesGrafana = module;
    services = module;
  };
}
