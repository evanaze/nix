{
  inputs,
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [inputs.hermes-agent.overlays.default];

  environment.systemPackages = with pkgs; [
    hermes-agent
  ];

  services.hermes-agent = {
    enable = true;
    settings = {
      model.default = "deepseek/deepseek-v4-flash";
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
    };
  };

  sops.secrets."hermes/env" = {
    owner = "hermes";
  };
}

