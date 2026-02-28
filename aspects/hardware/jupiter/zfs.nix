{pkgs, ...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e8a69b01"; # head -c4 /dev/urandom | od -A none -t x4

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/eye/documents 0755 evanaze users -"
    "f /mnt/eye/documents/.stfolder 0644 evanaze users -"
    "d /mnt/eye/downloads 0755 evanaze users -"
    "f /mnt/eye/downloads/.stfolder 0644 evanaze users -"
    "d /mnt/eye/media 0755 evanaze media -"
    "d /mnt/eye/movies 0755 evanaze users -"
    "f /mnt/eye/movies/.stfolder 0644 evanaze users -"
    "d /mnt/eye/music 0755 evanaze users -"
    "f /mnt/eye/music/.stfolder 0644 evanaze users -"
    "d /mnt/eye/pictures 0775 evanaze media -"
    "f /mnt/eye/pictures/.stfolder 0644 evanaze media -"
  ];

  systemd.services.syncthing = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };

  systemd.services.immich-server = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };

  systemd.services.jellyfin = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };
}
