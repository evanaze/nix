# aspects/core/networking.nix - NetworkManager configuration
{lib, ...}: {
  networking = {
    networkmanager.enable = lib.mkDefault true;
    nameservers = lib.mkDefault [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
