{...}: {
  services.alloy = {
    enable = true;
    configPath = ./config.alloy;
  };

  # Grant alloy access to read the systemd journal
  users.users.alloy = {
    group = "monitoring";
    isSystemUser = true;
    extraGroups = ["systemd-journal"];
  };

  users.groups.monitoring = {};
}
