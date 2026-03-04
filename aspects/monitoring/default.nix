# aspects/monitoring/default.nix - Monitoring configuration aggregator
{...}: {
  imports = [
    ./alloy.nix
    ./grafana.nix
    ./loki.nix
    ./prometheus.nix
  ];
}
