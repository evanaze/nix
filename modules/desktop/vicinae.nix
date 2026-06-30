let
  module = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      gnomeExtensions.vicinae
    ];

    home-manager.users.${username} = {
      programs.vicinae = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
in {
  flake.modules.nixos = {
    desktopVicinae = module;
    desktop = module;
  };
}
