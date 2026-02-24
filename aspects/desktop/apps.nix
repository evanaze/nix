# aspects/desktop/apps.nix - Desktop applications
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    brave
    code-cursor
    google-chrome
    hunspell
    hunspellDicts.en-us
    inkscape
    keymapp
    libreoffice-fresh
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

    # Zellij clipboard configuration for X11
    programs.zellij.settings = {
      copy_command = "xclip -selection clipboard";
    };
  };
}
