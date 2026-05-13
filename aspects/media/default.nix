# aspects/media/default.nix - Media configuration aggregator
{...}: {
  imports = [
    ./immich.nix
    # ./jellyfin.nix
    ./nixflix.nix
  ];
}
