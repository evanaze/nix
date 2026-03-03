# aspects/monitoring/grafana.nix - Grafana dashboards
{
  lib,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;
    port = 2342;
    addr = "127.0.0.1";
    settings.security.secret_key = "/run/secrets/grafana";
  };

  # systemd.services.grafana-tsserve = {
  #   after = [
  #     "tailscaled-autoconnect.service"
  #     "immich-server.service"
  #   ];
  #   wants = [
  #     "tailscaled-autoconnect.service"
  #     "immich-server.service"
  #   ];
  #   wantedBy = ["multi-user.target"];
  #   description = "Using Tailscale Serve to publish Grafana";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  #   script = "${lib.getExe pkgs.tailscale} serve --service=svc:monitoring --https=4431 http://127.0.0.1:2342";
  # };
}
