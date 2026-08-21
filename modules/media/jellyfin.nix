{
  flake.modules.nixos.mediaJellyfin =
    # aspects/media/jellyfin.nix - Jellyfin media server
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

      services.tailscale.serve.services.media.endpoints."tcp:443" = "http://127.0.0.1:8096";
    };
}
