{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    user = "evanaze";
  };

  systemd.services.tsserve-jellyfin = {
    after = ["tailscaled.service" "jellyfin.service"];
    wants = ["tailscaled.service" "jellyfin.service"];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Jellyfin";
    serviceConfig = {
      Type = "exec";
    };
    script = "${lib.getExe pkgs.tailscale} serve --bg https 443 --set-path /media 8096";
  };
}
