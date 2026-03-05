{
  lib,
  pkgs,
  ...
}: {
  services.actual.enable = true;

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
