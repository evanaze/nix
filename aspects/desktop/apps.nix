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
      spotify
      thunderbird
    ];

    # Thunderbird email configuration
    accounts.email.accounts = {
      evanaze = {
        name = "Evanaze Gmail";
        address = "evanaze@gmail.com";
        flavor = "gmail.com";
        primary = true;
        realName = "Evan Azevedo";
        thunderbird.enable = true;
      };
    };

    # Zellij clipboard configuration for X11
    programs.zellij.settings = {
      copy_command = "xclip -selection clipboard";
    };
  };
}
