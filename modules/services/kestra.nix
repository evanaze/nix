let
  module = {
    config,
    inputs,
    pkgs,
    lib,
    ...
  }: {
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
      port = 7398;
      database = {
        createLocally = true;
        passwordFile = config.sops.secrets."kestra/db-password".path;
      };
      encryptionSecretKeyFile = config.sops.secrets."kestra/encryption-secret-key".path;
      jdbcSecretKeyFile = config.sops.secrets."kestra/jdbc-secret-key".path;
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
        ${lib.getExe pkgs.tailscale} serve --service=svc:jobs --https=443 ${config.services.kestra.port}
      '';
    };
  };
in {
  flake.modules.nixos = {
    services = module;
  };
}
