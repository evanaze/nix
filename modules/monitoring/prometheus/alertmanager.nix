{
  flake.modules.nixos.prometheusAlertmanager = {...}: {
  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      route = {
        receiver = "ntfy";
        group_by = ["alertname" "host"];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      };
      receivers = [
        {
          name = "ntfy";
          webhook_configs = [
            {
              url = "http://127.0.0.1:8000/hook";
              send_resolved = true;
            }
          ];
        }
      ];
    };
  };
};
}
