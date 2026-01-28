# aspects/media/default.nix - Media configuration aggregator
{...}: {
  imports = [
    ./ipfs.nix
    # ./jellyfin.nix  # Enable when needed
  ];
}
