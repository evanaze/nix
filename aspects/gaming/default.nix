# aspects/gaming/default.nix - Gaming configuration aggregator
{...}: {
  imports = [
    ./steam.nix
    # ./slippi.nix  # Requires slippi module from flake
  ];
}
