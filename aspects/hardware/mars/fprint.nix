{...}: {
  services.fprintd.enable = true;

  security.pam.services = {
    gdm-lock.fprintAuth = true;
    login.fprintAuth = true;
    sudo.fprintAuth = true;
  };
}
