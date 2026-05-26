{
  pkgs,
  config,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.openviking.overlays.default];

  environment.systemPackages = with pkgs; [
    openviking
  ];

  services.openviking = {
    enable = true;
    configFile = config.sops.secrets."openviking/conf".path;
  };

  # Enable the CLI in interactive shells to share state
  # with the service
  environment.variables.OPENVIKING_CONFIG_FILE = config.sops.secrets."openviking/conf".path;

  sops.secrets."openviking/conf" = {
    owner = "openviking";
  };
}
