let
  module = {
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
      openFirewall = true;
      mediaLocation = "/mnt/eye/media/pictures";
    };

    # Ensure immich owns its data subdirectories so it can write to them
    systemd.tmpfiles.rules = let
      mediaDir = "/mnt/eye/media/pictures";
      immichDirs = ["encoded-video" "thumbs" "upload" "profile" "backups" "library"];
    in
      map (d: "d ${mediaDir}/${d} 0750 immich media -") immichDirs;

    services.tailscale.serve.services.photos.endpoints."tcp:443" = "http://localhost:2283";
  };
in {
  flake.modules.nixos = {
    mediaImmich = module;
    media = module;
  };
}
