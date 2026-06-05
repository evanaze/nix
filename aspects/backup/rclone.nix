{
  config,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.rclone.enable = true;

    systemd.user.services."rclone-knowledge-base-sync" = {
      Unit = {
        Description = "Sync Knowledge Base to iCloud Drive";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone sync '%h/Documents/Knowledge Base' 'iclouddrive:Obsidian/Knowledge Base'";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.timers."rclone-knowledge-base-sync" = {
      Unit = {
        Description = "Sync Knowledge Base to iCloud Drive every 5 minutes";
      };
      Timer = {
        OnCalendar = "*:0/5";
        Persistent = true;
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
