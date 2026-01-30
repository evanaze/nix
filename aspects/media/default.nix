# aspects/media/default.nix - Media configuration aggregator
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./ipfs.nix
    # ./jellyfin.nix  # Enable when needed
  ];

  # Home-manager language packages
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      calibre
    ];
  };
}
