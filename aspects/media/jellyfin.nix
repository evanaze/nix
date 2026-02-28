# aspects/media/jellyfin.nix - Jellyfin media server
{
  lib,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    user = username;
  };

  systemd.services.jellyfin-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Jellyfin";
    serviceConfig = {
      Type = "exec";
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:media --https=4433 8096";
  };
}
