{...}: {
  # environment.systemPackages = with pkgs; [
  #   jellyfin
  #   jellyfin-web
  #   jellyfin-ffmpeg
  # ];

  # services.jellyfin = {
  #   enable = true;
  #   user = "evanaze";
  # };
  services.plex = {
    enable = true;
  };
}
