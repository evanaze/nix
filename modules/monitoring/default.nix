let
  ntfyPort = 8117;
  alertmanagerNtfyPort = 8000;
in {
  flake.modules.nixos = {
    monitoring = {};

    monitoringNtfy = {
      lib,
      pkgs,
      ...
    }: {
      services.ntfy-sh = {
        enable = true;
        settings = {
          listen-http = "127.0.0.1:${toString ntfyPort}";
          base-url = "https://alerts.spitz-pickerel.ts.net";
          cache-file = "/var/lib/ntfy-sh/cache.db";
          behind-proxy = true;
        };
      };

      services.prometheus.alertmanager-ntfy = {
        enable = true;
        settings = {
          http.addr = "127.0.0.1:${toString alertmanagerNtfyPort}";
          ntfy = {
            baseurl = "http://127.0.0.1:${toString ntfyPort}";
            notification = {
              topic = "server-alerts";
              priority = ''
                status == "firing" ? "high" : "default"
              '';
              tags = [
                {
                  tag = "white_check_mark";
                  condition = ''status == "resolved"'';
                }
                {
                  tag = "rotating_light";
                  condition = ''status == "firing"'';
                }
              ];
              templates = {
                title = ''{{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}'';
                description = ''{{ index .Annotations "description" }}'';
                headers.X-Click = ''{{ .GeneratorURL }}'';
              };
            };
          };
        };
      };

      services.tailscale.serve.services.alerts.endpoints."tcp:443" = "http://127.0.0.1:${toString ntfyPort}";
    };
  };
}
