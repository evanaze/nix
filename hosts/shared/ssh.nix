{...}: {
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes"; # optional
  };
}
