let
  module = {
    lib,
    config,
    pkgs,
    username,
    ...
  }: let
    actualPort = 5006;
    actualCliOverlay = final: prev: {
      actual-cli = final.callPackage ../../pkgs/actual-cli {};
    };
  in {
    services.actual = {
      enable = true;
      user = username;
      settings = {
        port = actualPort;
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
        ${lib.getExe pkgs.actual-cli} server bank-sync --server-url http://localhost:${toString actualPort} --password ${config.sops.secrets.actual.path};
      '';
      serviceConfig = {
        Type = "oneshot";
        User = username;
        EnvironmentFile = config.sops.secrets.actual.path;
      };
    };

    services.tailscale.serve.services.budget.endpoints."tcp:443" = "https://127.0.0.1:${toString actualPort}";
  };
in {
  flake.modules.nixos = {
    servicesActual = module;
    services = module;
  };
}
