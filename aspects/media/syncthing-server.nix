{
  lib,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = false;
    guiPasswordFile = "/run/secrets/hs-admin-pass";
    settings = {
      gui = {
        user = "admin";
      };
    };
  };

  systemd.services.jellyfin-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "syncthing.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "syncthing.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Syncthing";
    serviceConfig = {
      Type = "exec";
    };
    script = "${lib.getExe pkgs.tailscale} serve --bg https 443 --set-path /media 8384";
  };
}
