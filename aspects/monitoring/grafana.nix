# aspects/monitoring/grafana.nix - Grafana dashboards
{...}: {
  services.grafana = {
    enable = true;
  };
}
