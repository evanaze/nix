# aspects/monitoring/prometheus.nix - Prometheus monitoring
{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        port = 9002;
        enabledCollectors = ["systemd"];
      };
    };

    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
            labels.host = "jupiter";
          }
          {
            targets = ["earth.spitz-pickerel.ts.net:9002"];
            labels.host = "earth";
          }
          {
            targets = ["mars.spitz-pickerel.ts.net:9002"];
            labels.host = "mars";
          }
          {
            targets = ["mercury.spitz-pickerel.ts.net:9002"];
            labels.host = "mercury";
          }
        ];
      }
      {
        job_name = "restic";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.restic.port}"];
            labels.host = "jupiter";
          }
        ];
      }
    ];

    # alertmanager = {
    #   enable = true;
    #   configuration = {
    #     route = {
    #       receiver = "telegram";
    #       group_by = ["alertname"];
    #       group_wait = "30s";
    #       group_interval = "5m";
    #       repeat_interval = "4h";
    #     };
    #     receivers = [
    #       {
    #         name = "telegram";
    #         telegram_configs = [
    #           {
    #             # TODO: Replace with your actual Telegram bot token
    #             bot_token = "YOUR_TELEGRAM_BOT_TOKEN";
    #             # TODO: Replace with your actual Telegram chat ID
    #             chat_id = 000000000;
    #             send_resolved = true;
    #           }
    #         ];
    #       }
    #     ];
    #   };
    # };
  };
}
