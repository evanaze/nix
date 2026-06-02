{
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets."searxng/env" = {};

  services.searx = {
    enable = true;
    environmentFile = config.sops.secrets."searxng/env".path;
    settings.server = {
      bind_address = "::1";
    };
  };

  systemd.services.searxng-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "searx.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "searx.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Searxng";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:search --https=4441 8312";
  };
}
