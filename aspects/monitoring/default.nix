# aspects/monitoring/default.nix - Monitoring configuration aggregator
{...}: {
  imports = [
    ./grafana.nix
    ./prometheus.nix
  ];
}
