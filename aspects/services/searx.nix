{config, ...}: {
  sops.secrets.searxng-env = {};

  services.searx = {
    enable = true;
    environmentFile = config.sops.secrets.searxng-env.path;
    settings.server = {
      bind_address = "::1";
    };
  };
}
