{...}: {
  imports = [
    ./seedbox
    ./slippi.nix
    ./zsh.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  ## Garbage collector
  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  system = {
    # Auto upgrade
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      # Daily 00:00
      dates = "daily UTC";
    };
  };

  services.tailscale.enable = true;
}
