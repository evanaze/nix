let
  module = {
  config,
  lib,
  pkgs,
  ...
}: let
  searxngPort = 8311;
  caddyPort = 8312;
in {
  sops.secrets."searxng/env" = {};

  services.searx = {
    enable = true;
    environmentFile = config.sops.secrets."searxng/env".path;
    settings.server = {
      bind_address = "127.0.0.1";
      port = searxngPort;
    };
  };

  services.caddy.virtualHosts."http://:${toString caddyPort}" = {
    extraConfig = ''
      reverse_proxy localhost:${toString searxngPort} {
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Host {host}
      }
    '';
  };

  systemd.services.searxng-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "tailscaled.service"
      "searx.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "tailscaled.service"
      "searx.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Searxng";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:search --https=4441 http://127.0.0.1:${toString caddyPort}";
  };
};
in {
  flake.modules.nixos = {
    servicesSearx = module;
    services = module;
  };
}
