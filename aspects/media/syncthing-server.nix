{...}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = false;
    guiPasswordFile = "/run/secrets/hs-admin-pass";
    settings = {
      gui = {
        user = "admin";
      };
    };
  };
}
