let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    paseoPort = 6767;
    tailnet = "spitz-pickerel.ts.net";
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      services.paseo = {
        enable = true;
        openFirewall = false;
        listenAddress = "127.0.0.1";
        settings = {
          features.webUi.enabled = true;
        };
      };

      # Tailscale Serve publishes Paseo inside the tailnet
      systemd.services.paseo-tsserve = {
        after = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "paseo.service"
        ];
        wants = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "paseo.service"
        ];
        wantedBy = ["multi-user.target"];
        description = "Using Tailscale Serve to publish Paseo";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";
        };
        script = ''
          ${lib.getExe pkgs.tailscale} serve clear svc:paseo || true
          ${lib.getExe pkgs.tailscale} serve --service=svc:paseo --https=443 http://127.0.0.1:${toString paseoPort}
        '';
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesPaseo = module;
    services = module;
  };
}