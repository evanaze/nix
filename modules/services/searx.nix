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
      settings = {
        server = {
          bind_address = "127.0.0.1";
          port = searxngPort;
        };
        search.formats = [
          "html"
          "json"
        ];
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

    services.tailscale.serve.services.search.endpoints."tcp:443" = "https://127.0.0.1:${toString caddyPort}";
  };
in {
  flake.modules.nixos = {
    servicesSearx = module;
    services = module;
  };
}
