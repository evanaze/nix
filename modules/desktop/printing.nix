let
  module = # aspects/desktop/printing.nix - CUPS printing support
{...}: {
  # Enable CUPS to print documents
  services.printing.enable = true;
};
in {
  flake.modules.nixos = {
    desktopPrinting = module;
    desktop = module;
  };
}
