# aspects/media/default.nix - Media configuration aggregator
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./immich.nix
    # ./jellyfin.nix  # Enable when needed
  ];
}
