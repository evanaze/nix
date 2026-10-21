let
  module = {
    lib,
    pkgs,
    ...
  }: let
    rsshubPort = 1200;
  in {
    services.rsshub = {
      enable = true;
      settings = {
        PORT = rsshubPort;
        FOLLOW_OWNER_USER_ID = "aze";
        FOLLOW_DESCRIPTION = "aze's instance";
        FOLLOW_USER_LIMIT = "100";
      };
      redis = {
        enable = true;
        createLocally = false;
        host = "127.0.0.1";
        port = 6379;
      };
    };

    systemd.services.rsshub = {
      after = ["redis-default.service"];
      requires = ["redis-default.service"];
    };

    systemd.services.rsshub-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "rsshub.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "tailscaled.service"
        "rsshub.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish RSSHub";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve --service=svc:rsshub --https=443 http://127.0.0.1:${toString rsshubPort}
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesRssHub = module;
    services = module;
  };
}
