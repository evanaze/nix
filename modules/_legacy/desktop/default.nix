# aspects/desktop/default.nix - Desktop configuration aggregator
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./email.nix
    ./fonts.nix
    ./gnome.nix
    ./printing.nix
    ./sound.nix
    ./xserver.nix
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    brave
    # calibre
    code-cursor
    google-chrome
    hunspell
    hunspellDicts.en-us
    inkscape
    jellyfin-desktop
    keymapp
    libreoffice-fresh
    picard
    python314
    slack
    xclip
    zoom-us
  ];

  # Home-manager desktop apps
  home-manager.users.${username} = {pkgs, ...}: {
    home.packages = with pkgs; [
      firefox
      obsidian
    ];
  };
}
