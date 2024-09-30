{
  username,
  pkgs,
  ...
}: {
  # Set your time zone.
  time.timeZone = "America/Denver";

  users.users.${username} = {
    initialPassword = "password";
    isNormalUser = true;
    description = "Evan Azevedo";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
  };

  # Enale sudo with no password for user
  security.sudo.extraRules = [
    {
      users = ["${username}"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
