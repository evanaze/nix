let
  module = {
    config,
    inputs,
    pkgs,
    lib,
    ...
  }: let
    caddyPort = 7398;
    kestraPort = 7399;
  in {
    nixpkgs.overlays = [inputs.kestra-nix.overlays.default];

    environment.systemPackages = [pkgs.kestra];

    sops.secrets = {
      "kestra/db-password" = {
        owner = "kestra";
      };
      "kestra/encryption-secret-key" = {
        owner = "kestra";
      };
      "kestra/jdbc-secret-key" = {
        owner = "kestra";
      };
    };

    services.kestra = {
      enable = true;
      port = kestraPort;
      database = {
        createLocally = true;
        passwordFile = config.sops.secrets."kestra/db-password".path;
      };
      encryptionSecretKeyFile = config.sops.secrets."kestra/encryption-secret-key".path;
      jdbcSecretKeyFile = config.sops.secrets."kestra/jdbc-secret-key".path;
    };

    services.caddy.virtualHosts."http://:${toString caddyPort}" = {
      extraConfig = ''
        reverse_proxy localhost:${toString kestraPort} {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Host {host}
        }
      '';
    };

    systemd.services.kestra-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "kestra.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "kestra.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Kestra";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:jobs || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:jobs --https=443 ${toString caddyPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    services = module;
  };
}
