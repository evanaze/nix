{
  flake.modules.nixos.desktop = {pkgs, username, ...}: {
    environment.systemPackages = with pkgs; [
      bitwarden-desktop
      brave
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

    home-manager.users.${username} = {pkgs, ...}: {
      home.packages = with pkgs; [
        firefox
        obsidian
      ];
    };
  };
}
