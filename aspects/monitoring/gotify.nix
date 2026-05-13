{...}: {
  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_SERVER_PORT = 8117;
      GOTIFY_DATABASE_DIALECT = "sqlite3";
    };
  };

  # services.prometheus.alertmanagerGotify = {
  #   enable = true;
  #   metrics.username = "admin";
  # };
}
