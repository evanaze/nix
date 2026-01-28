# aspects/desktop/fonts.nix - System fonts
{pkgs, ...}: {
  fonts.packages = with pkgs; [
    iosevka
  ];
}
