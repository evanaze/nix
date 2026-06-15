let
  module = # aspects/desktop/fonts.nix - System fonts
{pkgs, ...}: {
  fonts.packages = with pkgs; [
    iosevka
  ];
};
in {
  flake.modules.nixos = {
    desktopFonts = module;
    desktop = module;
  };
}
