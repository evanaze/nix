let
  module = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      programs.rclone.enable = true;

      systemd.user.services = {
        "rclone-documents-sync" = {
          Unit.Description = "Bi-directional sync Documents folder with iCloud Drive";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync %h/Documents iclouddrive:Documents --exclude /StackMagic/** --exclude '/Knowledge Base/**' --resilient --recover --conflict-resolve newer --max-delete 10 --create-empty-src-dirs";
          };
        };

        "rclone-downloads-sync" = {
          Unit.Description = "Bi-directional sync Downloads folder with iCloud Drive";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync %h/Downloads iclouddrive:Downloads --resilient --recover --conflict-resolve newer --force --create-empty-src-dirs";
          };
        };

        "rclone-knowledge-base-sync" = {
          Unit.Description = "Bi-directionally sync the Knowledge Base vault with iCloud Drive";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync '%h/Documents/Knowledge Base' 'iclouddrive:Obsidian/Knowledge Base' --resilient --recover --conflict-resolve newer --max-delete 10 --create-empty-src-dirs";
          };
        };

        "rclone-stackmagic-sync" = {
          Unit.Description = "Bi-directional sync StackMagic vault with iCloud Drive";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync %h/Documents/StackMagic iclouddrive:Obsidian/StackMagic --resilient --recover --conflict-resolve newer --max-delete 10 --create-empty-src-dirs";
          };
        };
      };

      systemd.user.timers = {
        "rclone-documents-sync" = {
          Unit.Description = "Bi-directional sync the Documents folder every 5 minutes";
          Install = {WantedBy = ["timers.target"];};
          Timer = {
            OnCalendar = "*:0/5";
            Persistent = true;
          };
        };

        "rclone-downloads-sync" = {
          Unit.Description = "Bi-directional sync the Downloads folder every 5 minutes";
          Install = {WantedBy = ["timers.target"];};
          Timer = {
            OnCalendar = "*:0/5";
            Persistent = true;
          };
        };

        "rclone-knowledge-base-sync" = {
          Unit.Description = "Bi-directional sync the Knowledge Base vault every 5 minutes";
          Install.WantedBy = ["timers.target"];
          Timer = {
            OnCalendar = "*:2/7";
            Persistent = true;
          };
        };

        "rclone-stackmagic-sync" = {
          Unit.Description = "Bi-directional sync the StackMagic vault every 5 minutes";
          Install.WantedBy = ["timers.target"];
          Timer = {
            OnCalendar = "*:1/6";
            Persistent = true;
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    backupRclone = module;
    backup = module;
  };
}
