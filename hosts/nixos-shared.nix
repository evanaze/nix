{...}: {
  # Set your time zone.
  time.timeZone = "America/Denver";

  ## Garbage collector
  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  services.tailscale.enable = true;
}
