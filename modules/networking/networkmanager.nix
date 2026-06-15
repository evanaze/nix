let
  module = # aspects/networking/networkmanager.nix - NetworkManager for desktop networking
{...}: {
  networking = {
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
};
in {
  flake.modules.nixos = {
    networkingNetworkmanager = module;
    networking = module;
  };
}
