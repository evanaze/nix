let
  textfileDirectory = "/var/lib/node_exporter/textfile_collector";
  module = # aspects/monitoring/node-exporter.nix - Prometheus node exporter for client machines
{...}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9002;
    enabledCollectors = ["systemd" "textfile"];
    extraFlags = ["--collector.textfile.directory=${textfileDirectory}"];
  };

  systemd.tmpfiles.rules = [
    "d ${textfileDirectory} 0755 root root -"
  ];

  # Allow prometheus on jupiter to scrape via Tailscale
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [9002];
};
in {
  flake.modules.nixos = {
    prometheusNodeExporter = module;
    monitoring = module;
  };
}
