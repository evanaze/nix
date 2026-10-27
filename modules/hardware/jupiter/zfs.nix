let
  textfileDirectory = "/var/lib/node_exporter/textfile_collector";
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

    systemd.services.zfs-health-metrics = {
      description = "Export ZFS pool health metrics for Prometheus";
      after = ["zfs-import.target"];
      wants = ["zfs-import.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        set -eu
        mkdir -p ${textfileDirectory}
        tmp=$(mktemp ${textfileDirectory}/zfs_health.prom.XXXXXX)
        if ${pkgs.zfs}/bin/zpool status -x | ${pkgs.gnugrep}/bin/grep -q "all pools are healthy"; then
          status=1
        else
          status=0
        fi
        {
          echo '# HELP zfs_pools_healthy Whether all imported ZFS pools are healthy according to zpool status -x.'
          echo '# TYPE zfs_pools_healthy gauge'
          echo "zfs_pools_healthy $status"
        } > "$tmp"
        chmod 0644 "$tmp"
        mv "$tmp" ${textfileDirectory}/zfs_health.prom
      '';
    };

    systemd.timers.zfs-health-metrics = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitActiveSec = "1m";
        Unit = "zfs-health-metrics.service";
      };
    };

    # Create ZFS datasets for app state on the redundant pool and fix ownership
    systemd.services.create-appdata-datasets = {
      description = "Create appdata datasets on eye pool";
      after = ["zfs-mount.service"];
      before = [
        "grafana.service"
        "jellyfin.service"
        "hermes-agent.service"
        "hermes-stackmagic-profile.service"
        "donetick.service"
        "chromadb.service"
        "redis-falkordb.service"
      ];
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
        for ds in actual chromadb donetick falkordb grafana hermes jellyfin; do
          if ! ${pkgs.zfs}/bin/zfs list eye/appdata/$ds >/dev/null 2>&1; then
            ${pkgs.zfs}/bin/zfs create -o mountpoint=legacy eye/appdata/$ds
          fi
        done
        # POSIX ACLs are used to grant evanaze read-only access to the hermes
        # appdata (group-write would trip the hermes gateway permission check)
        ${pkgs.zfs}/bin/zfs set acltype=posixacl eye/appdata/hermes || true
        chown evanaze:users /mnt/eye/appdata/actual || true
        chown -R chromadb:chromadb /mnt/eye/appdata/chromadb || true
        chown evanaze:users /mnt/eye/appdata/donetick || true
        chown redis-falkordb:redis-falkordb /mnt/eye/appdata/falkordb || true
        chown grafana:grafana /mnt/eye/appdata/grafana || true
        chown hermes:hermes /mnt/eye/appdata/hermes || true
        chown evanaze:jellyfin /mnt/eye/appdata/jellyfin || true
      '';
    };

    # The upstream hermes-agent NixOS module ships tmpfiles rules forcing
    # 2770 (group-writable) on these paths in 00-nixos.conf, and the first
    # tmpfiles rule for a path wins. Group-write trips the hermes gateway's
    # unsafe_control_permissions check, so override with an earlier-sorted
    # config file (tmpfiles reads /etc/tmpfiles.d/*.conf lexicographically).
    environment.etc."tmpfiles.d/0-hermes-home-perms.conf".text = ''
      d /mnt/eye/appdata/hermes 0750 hermes hermes -
      d /mnt/eye/appdata/hermes/.hermes 0750 hermes hermes -
    '';

    systemd.tmpfiles.rules = [
      "d /mnt/eye/appdata 0755 root root -"
      "d /mnt/eye/appdata/actual 0750 evanaze users -"
      "d /mnt/eye/appdata/chromadb 0750 chromadb chromadb -"
      "d /mnt/eye/appdata/donetick 0755 evanaze users -"
      "d /mnt/eye/appdata/falkordb 0750 evanaze users -"
      "d /mnt/eye/appdata/grafana 0750 grafana grafana -"
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

    # The hermes gateway refuses to start when /mnt/eye/appdata/hermes/.hermes
    # is writable by another user (unsafe_control_permissions), so instead of
    # group-write, grant evanaze read-only access via POSIX ACLs. The default
    # ACL entries keep new files readable; the mask stays r-x so the mode
    # remains 0750 and the gateway check passes.
    # deps on hermes-agent-setup: the upstream hermes-agent module's
    # activation script chmods these dirs to 2770 on every switch; this
    # script must run after it to restore 0750 and apply the ACLs.
    system.activationScripts.hermesAppdataAcl = {
      deps = ["users" "hermes-agent-setup"];
      text = ''
        setfacl=${pkgs.acl}/bin/setfacl
        find=${pkgs.findutils}/bin/find

        appdata=/mnt/eye/appdata/hermes
        if [ -d "$appdata" ]; then
          chown hermes:hermes "$appdata" || true
          chmod 0750 "$appdata"
          chmod g-s "$appdata" || true
          "$setfacl" -m u:evanaze:r-x,d:u:evanaze:r-x "$appdata"

          if [ -d "$appdata/.hermes" ]; then
            chown hermes:hermes "$appdata/.hermes" || true
            chmod 0750 "$appdata/.hermes"
            chmod g-s "$appdata/.hermes" || true
            "$setfacl" -m u:evanaze:r-x "$appdata/.hermes"
            "$find" "$appdata/.hermes" -type d -exec "$setfacl" -m u:evanaze:r-x,d:u:evanaze:r-x {} +
            "$find" "$appdata/.hermes" -type f -perm /111 -exec "$setfacl" -m u:evanaze:r-x {} +
            "$find" "$appdata/.hermes" -type f ! -perm /111 -exec "$setfacl" -m u:evanaze:r {} +
          fi
        fi
      '';
    };

    systemd.services.syncthing = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.immich-server = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.chromadb = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.donetick = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.falkordb = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.grafana = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.hermes-agent = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.services.jellyfin = {
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
