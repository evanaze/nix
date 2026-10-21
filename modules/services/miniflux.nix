let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    minifluxPort = 8080;
  in {
    users.groups.miniflux = {};
    users.users.miniflux = {
      isSystemUser = true;
      group = "miniflux";
    };

    sops.templates."miniflux-admin.env" = {
      owner = "miniflux";
      group = "miniflux";
      mode = "0400";
      content = ''
        ADMIN_USERNAME=aze
        ADMIN_PASSWORD=${config.sops.placeholder.admin-pass}
      '';
    };

    services.miniflux = {
      enable = true;
      # Creates the `miniflux` database and PostgreSQL role (peer auth via
      # the local socket, matching postgres.nix's sameuser map).
      createDatabaseLocally = true;
      adminCredentialsFile = config.sops.templates."miniflux-admin.env".path;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString minifluxPort}";
        BASE_URL = "https://feed.spitz-pickerel.ts.net";
        RUN_MIGRATIONS = 1;
        CREATE_ADMIN = 1;
      };
    };

    # Run as the dedicated static user instead of the module's DynamicUser
    # so PostgreSQL peer authentication maps cleanly.
    systemd.services.miniflux.serviceConfig = {
      DynamicUser = lib.mkForce false;
      PrivateUsers = lib.mkForce false;
      User = "miniflux";
      Group = "miniflux";
    };

    systemd.services.miniflux-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "miniflux.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "miniflux.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Miniflux";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve --service=svc:feed --https=443 http://127.0.0.1:${toString minifluxPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesMiniflux = module;
    services = module;
  };
}
