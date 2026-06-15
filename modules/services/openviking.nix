let
  module = {
  pkgs,
  lib,
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
    group = "users";
    mode = "0440";
  };

  systemd.services.openviking-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "openviking.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "openviking.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Openviking";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:memory || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:memory --https=443 http://localhost:1933
    '';
  };
};
in {
  flake.modules.nixos = {
    servicesOpenviking = module;
    services = module;
  };
}
