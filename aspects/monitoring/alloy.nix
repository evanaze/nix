{...}: {
  services.alloy = {
    enable = true;
    configPath = ./config.alloy;
  };

  # Grant alloy access to read the systemd journal
  users.users.alloy.extraGroups = ["systemd-journal"];
}
