{username, ...}: {
  # Set your time zone.
  time.timeZone = "America/Denver";

  ## Garbage collector
  programs.nh = {
    enable = true;
    flake = "/home/${username}/.config/nix/flake.nix";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
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
