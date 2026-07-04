let
  module = {username, ...}: {
    home-manager.users.${username} = {
      programs.devenv = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentDevenv = module;
    development = module;
  };
}
