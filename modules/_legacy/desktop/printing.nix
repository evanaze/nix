# aspects/desktop/printing.nix - CUPS printing support
{...}: {
  # Enable CUPS to print documents
  services.printing.enable = true;
}
