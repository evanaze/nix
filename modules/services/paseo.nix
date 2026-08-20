let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    paseoPort = 6767;
    caddyPort = 6768;
  in {
    services.paseo = {
      enable = true;
      openFirewall = false;
      listenAddress = "127.0.0.1";
      hostnames = [".spitz-pickerel.ts.net"];
      settings = {
        features.webUi.enabled = true;
      };
    };

    services.caddy.virtualHosts."http://:${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString paseoPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    services.tailscale.serve.services.paseo.endpoints."tcp:443" = "http://127.0.0.1:${toString caddyPort}";
  };
in {
  flake.modules.nixos = {
    servicesPaseo = module;
    services = module;
  };
}
