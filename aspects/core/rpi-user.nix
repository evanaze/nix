# aspects/core/rpi-user.nix - User account configuration for Raspberry Pi
{
  username,
  pkgs,
  ...
}: {
  users.groups.${username} = {};

  users.users.${username} = {
    initialPassword = "password";
    isNormalUser = true;
    description = "Evan Azevedo";
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Enable sudo with no password for user
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
