# aspects/monitoring/default.nix - Monitoring configuration aggregator
{...}: {
  imports = [
    ./alloy.nix
    ./prometheus/node-exporter.nix
  ];
}
