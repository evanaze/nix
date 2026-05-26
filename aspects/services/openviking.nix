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
    configFile = config.sops.secrets.openviking-conf.path;
  };

  sops.secrets.openviking-conf = {owner="openviking"};
}
