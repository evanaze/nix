{
  config,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.rclone = {
      enable = true;
      remotes = {
        iclouddrive = {
          config = {
            type = "iclouddrive";
            apple_id = "me@evanazevedo.com";
          };
          secrets.password = config.sops.secrets.Icloud-password.path;
        };
      };
    };
  };
}
