{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../shared.nix
    ./homebrew.nix
  ];

  users.users.${username} = {
    home = "/Users/" + username;
    shell = pkgs.zsh;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  # Backups using RClone and Tailscale Taildrive
  launchd.agents.rclone = {
    command = "/usr/local/bin/rclone sync /Users/evanaze rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/current --backup-dir=rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/archive/`date -I`";
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

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
    };
  };
}
