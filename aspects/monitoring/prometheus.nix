# aspects/monitoring/prometheus.nix - Prometheus monitoring
{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        port = 9002;
        enabledCollectors = ["systemd"];
      };
    };

    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
            labels.host = "jupiter";
          }
          {
            targets = ["earth.spitz-pickerel.ts.net:9002"];
            labels.host = "earth";
          }
          {
            targets = ["mars.spitz-pickerel.ts.net:9002"];
            labels.host = "mars";
          }
          {
            targets = ["mercury.spitz-pickerel.ts.net:9002"];
            labels.host = "mercury";
          }
        ];
      }
      {
        job_name = "restic";
        static_configs = [
          {
            targets = ["http://127.0.0.1:9753"];
            labels.host = "jupiter";
          }
        ];
      }
      {
        job_name = "restic";
        static_configs = [
          {
            targets = ["127.0.0.1:8000"];
            labels.host = "jupiter";
          }
        ];
      }
    ];
  };
}
