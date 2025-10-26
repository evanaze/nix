{pkgs, ...}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  environment = {
    variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory
    systemPackages = [pkgs.libsecret]; # libsecret API
  };
}
