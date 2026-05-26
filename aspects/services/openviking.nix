{
  pkgs,
  config,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.openviking.overlays.default];

  services.openviking = {
    enable = true;
    configFile = config.sops.secrets.openviking-conf.path;
  };

  environment.systemPackages = with pkgs; [
    openviking
  ];
}
