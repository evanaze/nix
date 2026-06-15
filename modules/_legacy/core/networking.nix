# aspects/core/networking.nix - NetworkManager configuration
{
  hostname,
  lib,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    nameservers = lib.mkDefault [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
