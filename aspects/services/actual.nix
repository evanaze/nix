{
  lib,
  pkgs,
  username,
  ...
}: {
  services.actual = {
    enable = true;
    user = username;
    settings = {
      port = 5006;
    };
  };

  # Service to sync transactions from bank
  # systemd.timers."actual-sync" = {
  #   after = ["actual.service"];
  #   wantedBy = ["timers.target"];
  #   timerConfig = {
  #     OnBootSec = "5m";
  #     OnUnitActiveSec = "5m";
  #     Unit = "actual-sync.service";
  #   };
  # };

  # systemd.services."actual-sync" = {
  #   script = ''
  #     set -eu
  #     actual-server sync
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };

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
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:budget --https=4432 5006";
  };
}
