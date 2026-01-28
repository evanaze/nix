# aspects/desktop/gnome.nix - GNOME desktop environment
{username, ...}: {
  services.desktopManager.gnome.enable = true;

  services.displayManager = {
    autoLogin = {
      enable = false;
      user = username;
    };
    gdm.enable = true;
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
