{...}: {
  imports = [
    ./plymouth.nix
  ];

  hardware.bluetooth.enable = true;
}
