{
  username,
  config,
  pkgs,
  ...
}: {
  users.users.${username} = {
    initialPassword = "password";
    isNormalUser = true;
    description = "Evan Azevedo";
    extraGroups = [
      "networkmanager"
      "wheel"
      config.services.kubo.group
    ];
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
}
