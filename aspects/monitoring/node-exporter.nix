# aspects/monitoring/node-exporter.nix - Prometheus node exporter for client machines
{...}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9002;
    enabledCollectors = ["systemd"];
  };

  # Allow prometheus on jupiter to scrape via Tailscale
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [9002];
}
