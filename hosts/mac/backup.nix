{
  lib,
  pkgs,
  ...
}: let
  syncScript = ''
    #!/bin/bash

    # List of folders to sync
    folders=("Documents" "Music" "Movies")

    # Loop through each folder and run the rclone sync command
    for folder in "$\{folders[@]\}"; do
        echo "Syncing folder: $folder"

        ${lib.getExe pkgs.rclone} sync "/Users/evanaze/$folder" \
            "rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/current/$folder" \
            --backup-dir="rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/archive/$(date -I)/$folder" \
            --config="/Users/evanaze/.config/rclone/rclone.conf"

        echo "Finished syncing $folder"
    done
  '';
in {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Backups using RClone and Tailscale Taildrive
  launchd.agents.rclone = {
    script = syncScript;
    serviceConfig = {
      KeepAlive = false;
      ProcessType = "Background";
      StartCalendarInterval = {
        Hour = 0;
        Minute = 0;
      };
      StandardErrorPath = "/tmp/rclone.err";
      StandardOutPath = "/tmp/rclone.out";
    };
  };
}
