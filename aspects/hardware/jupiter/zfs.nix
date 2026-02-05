{...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e8a69b01"; # head -c4 /dev/urandom | od -A none -t x4
}
