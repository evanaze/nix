# aspects/desktop/default.nix - Desktop configuration aggregator
{...}: {
  imports = [
    ./apps.nix
    ./email.nix
    ./fonts.nix
    ./gnome.nix
    ./printing.nix
    ./sound.nix
    ./xserver.nix
  ];
}
