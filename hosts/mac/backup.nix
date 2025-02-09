{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Backups using RClone and Tailscale Taildrive
  launchd.agents.rclone = {
    command = "${pkgs.rclone} sync /Users/evanaze/Documents rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/current/Documents --backup-dir=rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/archive/Documents`date -I` --config=/Users/evanaze/.config/rclone/rclone.conf";
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
