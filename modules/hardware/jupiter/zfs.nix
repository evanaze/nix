let
  module = {pkgs, ...}: {
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e8a69b01";

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  # Create ZFS datasets for app state on the redundant pool and fix ownership
  systemd.services.create-appdata-datasets = {
    description = "Create appdata datasets on eye pool";
    after = ["zfs-mount.service"];
    before = ["grafana.service" "jellyfin.service" "hermes-agent.service" "donetick.service"];
    wants = ["zfs-mount.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ! ${pkgs.zfs}/bin/zfs list eye/appdata >/dev/null 2>&1; then
        ${pkgs.zfs}/bin/zfs create -o mountpoint=/mnt/eye/appdata eye/appdata
      fi
      for ds in actual donetick grafana hermes jellyfin; do
        if ! ${pkgs.zfs}/bin/zfs list eye/appdata/$ds >/dev/null 2>&1; then
          ${pkgs.zfs}/bin/zfs create -o mountpoint=legacy eye/appdata/$ds
        fi
      done
      chown evanaze:users /mnt/eye/appdata/actual || true
      chown evanaze:users /mnt/eye/appdata/donetick || true
      chown grafana:grafana /mnt/eye/appdata/grafana || true
      chown hermes:hermes /mnt/eye/appdata/hermes || true
      chown evanaze:jellyfin /mnt/eye/appdata/jellyfin || true
    '';
  };

  systemd.tmpfiles.rules = [
    "d /mnt/eye/appdata 0755 root root -"
    "d /mnt/eye/appdata/actual 0750 evanaze users -"
    "d /mnt/eye/appdata/donetick 0755 evanaze users -"
    "d /mnt/eye/appdata/grafana 0750 grafana grafana -"
    "d /mnt/eye/appdata/hermes 0750 hermes hermes -"
    "d /mnt/eye/documents 0755 evanaze users -"
    "f /mnt/eye/documents/.stfolder 0644 evanaze users -"
    "d /mnt/eye/downloads 0755 evanaze users -"
    "f /mnt/eye/downloads/.stfolder 0644 evanaze users -"
    "d /mnt/eye/media 0755 root root -"
    "d /mnt/eye/media/pictures 0755 evanaze media -"
    "d /mnt/eye/movies 0755 evanaze users -"
    "f /mnt/eye/movies/.stfolder 0644 evanaze users -"
    "d /mnt/eye/music 0755 evanaze users -"
    "f /mnt/eye/music/.stfolder 0644 evanaze users -"
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

  systemd.services.grafana = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };

  systemd.services.donetick = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };

  systemd.services.hermes-agent = {
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
  };
};
in {
  flake.modules.nixos = {
    hardwareJupiterZfs = module;
    hardwareJupiter = module;
  };
}
