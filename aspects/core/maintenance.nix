# aspects/core/maintenance.nix - Auto-upgrade and garbage collection
{username, ...}: {
  # Garbage collector using nh
  programs.nh = {
    enable = true;
    flake = "/home/${username}/.config/nix";
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
}
