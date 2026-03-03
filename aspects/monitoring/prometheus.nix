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
        job_name = "chrysalis";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
  };
}
