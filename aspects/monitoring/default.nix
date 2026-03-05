# aspects/monitoring/default.nix - Monitoring configuration aggregator
{...}: {
  imports = [
    ./grafana.nix
    ./loki.nix
    ./prometheus.nix
  ];
}
