# aspects/development/git.nix - Git configuration (system + home-manager)
{username, ...}: {
  # Home-manager git configuration
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Evan Azevedo";
          email = "me@evanazevdo.com";
        };
        init.defaultBranch = "main";
        pull.rebase = "false";
      };
    };
  };
}
