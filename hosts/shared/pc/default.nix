{
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    ./games.nix
    ./ipfs.nix
    ./sound.nix
    ./user-evanaze.nix
    ./window-manager.nix
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    brave
    claude-code
    code-cursor
    google-chrome
    gnome-terminal
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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  fonts.packages = with pkgs; [
    iosevka
  ];
}
