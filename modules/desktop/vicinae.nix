let
  module = {username, ...}: {
    home-manager.users.${username} = {
      programs.vicinae = {
        enable = true;
      };
    };
  };
in {
  flake.modules.nixos = {
    desktopVicinae = module;
    desktop = module;
  };
}
