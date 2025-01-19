{...}: {
  services.grafana = {
    enable = true;
  };

  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
  };
}
