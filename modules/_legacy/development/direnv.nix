# aspects/development/direnv.nix - direnv for automatic environment loading
{username, ...}: {
  # Home-manager direnv configuration
  home-manager.users.${username} = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
