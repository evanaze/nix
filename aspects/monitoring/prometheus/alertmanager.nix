{...}: {
  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      route = {
        receiver = "telegram";
        group_by = ["alertname"];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      };
      receivers = [
        {
          name = "telegram";
          telegram_configs = [
            {
              # TODO: Replace with your actual Telegram bot token
              bot_token = "YOUR_TELEGRAM_BOT_TOKEN";
              # TODO: Replace with your actual Telegram chat ID
              chat_id = 000000000;
              send_resolved = true;
            }
          ];
        }
      ];
    };
  };
}
