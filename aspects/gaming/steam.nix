# aspects/gaming/steam.nix - Steam and gaming packages
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    shattered-pixel-dungeon
    steam
    zeroad
  ];

  # Home-manager gaming packages
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      steam
    ];
  };
}
