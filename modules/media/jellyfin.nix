{
  flake.modules.nixos.mediaJellyfin = # aspects/media/jellyfin.nix - Jellyfin media server
{
  lib,
  pkgs,
  username,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    user = username;
    dataDir = "/mnt/eye/appdata/jellyfin";
  };

  users.users.${username}.extraGroups = [
    "video"
    "render"
  ];

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
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:media || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:media --https=443 8096
    '';
  };
};
}
