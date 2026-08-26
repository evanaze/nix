let
  module = {
    lib,
    config,
    pkgs,
    username,
    ...
  }: let
    actualCliOverlay = final: prev: {
      actual-cli = final.callPackage ../../pkgs/actual-cli {};
    };
  in {
    services.actual = {
      enable = true;
      user = username;
      settings = {
        port = 5006;
        dataDir = "/mnt/eye/appdata/actual";
      };
    };

    # Service to sync transactions from bank daily at 2 AM
    systemd.timers."actual-sync" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "02:00:00";
        Persistent = true;
        Unit = "actual-sync.service";
      };
    };

    nixpkgs.overlays = [actualCliOverlay];
    sops.secrets.actual = {};

    systemd.services."actual-sync" = {
      after = ["actual.service"];
      requires = ["actual.service"];
      description = "Sync Actual Budget bank transactions";
      script = ''
        set -eu
        ${lib.getExe pkgs.actual-cli} server bank-sync --server-url http://localhost:5006;
      '';
      serviceConfig = {
        Type = "oneshot";
        User = username;
        EnvironmentFile = config.sops.secrets.actual.path;
      };
    };

    systemd.services.actual-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "actual.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "actual.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Actual";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:budget || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:budget --https=443 5006
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesActual = module;
    services = module;
  };
}
