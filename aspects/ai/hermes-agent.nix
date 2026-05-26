{...}: {
  services.hermes-agent = {
    enable = true;
    settings = {
      model.default = "deepseek/deepseek-v4-flash";
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
    };
  };
}

