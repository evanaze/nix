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

  services.fcron = {
    enable = true;
    systab = ''
      0 0 * * * rclone sync /Users/evanaze rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/current --backup-dir=rpi:kb9n9h7fxq@privaterelay.appleid.com/hs/backup/mac/archive/`date -I`
    '';
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
