{pkgs, ...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e8a69b01"; # head -c4 /dev/urandom | od -A none -t x4
  # zpool create -f -o ashift=12 atime=off -m /mnt/eye eye \
  #   raidz \
  #   ata-WDC_WD120EAGZ-00CRJB0_WD-B00N465D \
  #   ata-WDC_WD120EAGZ-00CRJB0_WD-B00N73PD \
  #   ata-WDC_WD120EAGZ-00CRJB0_WD-B00NAZ1D

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-1,15 02:30";
  };
}
