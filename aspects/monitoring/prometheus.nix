# aspects/monitoring/prometheus.nix - Prometheus monitoring
{...}: {
  services.prometheus = {
    enable = false;
    exporters.node.enable = true;

    globalConfig.scrape_interval = "15s";

    scrapeConfigs.mtrc.job_name = "node";
    scrapeConfigs.mtrc.staticConfigs.mtrc.targets = ["localhost:9100"];
  };
}
