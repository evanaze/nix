# aspects/networking/default.nix - Networking configuration aggregator
{...}: {
  imports = [
    ./networkmanager.nix
    # ./blocky.nix  # Enable for DNS servers
  ];
}
