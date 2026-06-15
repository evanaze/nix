# aspects/gaming/steam.nix - Steam and gaming packages
{pkgs, ...}: {
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    shattered-pixel-dungeon
    # Temporarily disabled - 0ad failing to build on unstable
    # zeroad
  ];
}
