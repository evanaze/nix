let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    radicalePort = 5232;
    caddyPort = 5233;
  in {
    services.radicale = {
      enable = true;
      settings = {
        server.hosts = ["0.0.0.0:${toString radicalePort}"];
        auth.type = "none";
      };
    };

    services.caddy.virtualHosts."http://:${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString radicalePort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    systemd.services.radicale-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "radicale.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "radicale.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Radicale";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:cal || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:cal --https=443 http://127.0.0.1:${toString caddyPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesRadicale = module;
    services = module;
  };
}
