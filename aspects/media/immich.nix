{
  lib,
  pkgs,
  username,
  ...
}: {
  users.groups.media = {};

  users.users.${username}.extraGroups = ["media"];

  services.immich = {
    enable = true;
    group = "media";
    port = 2283;
    mediaLocation = "/mnt/eye/pictures";
  };

  systemd.services.immich-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "immich-server.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "immich-server.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Immich";
    serviceConfig = {
      Type = "exec";
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:photos --https=443 2283";
  };
}
