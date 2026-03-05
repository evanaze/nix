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
      hostname = "budget.spitz-pickerel.ts.net";
      port = 5006;
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
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:budget --https=4432 5006";
  };
}
