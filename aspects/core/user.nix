# aspects/core/user.nix - User account configuration
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
