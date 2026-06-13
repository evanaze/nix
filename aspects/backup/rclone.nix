{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.rclone.enable = true;

    systemd.user.services."rclone-knowledge-base-sync" = {
      Unit = {
        Description = "Bi-directional sync Knowledge Base with iCloud Drive";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.rclone}/bin/rclone bisync '%h/Documents/Knowledge Base' 'iclouddrive:Obsidian/Knowledge Base' --resilient --recover --conflict-resolve newer --max-delete 10 --create-empty-src-dirs";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.timers."rclone-knowledge-base-sync" = {
      Unit = {
        Description = "Bi-directional sync Knowledge Base every 5 minutes";
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
