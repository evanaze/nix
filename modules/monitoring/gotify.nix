{
  flake.modules.nixos.monitoringGotify = {config, ...}: {
  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_SERVER_PORT = 8117;
      GOTIFY_DATABASE_DIALECT = "sqlite3";
    };
  };

  services.prometheus.alertmanagerGotify = {
    enable = true;
    port = config.services.gotify.environment.GOTIFY_SERVER_PORT;
    metrics.username = "admin";
    messageAnnotation = "description";
  };
};
}
