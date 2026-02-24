{
  username,
  pkgs,
  ...
}: {
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      # Temporarily disabled - calibre failing to build on unstable
      # See: https://github.com/NixOS/nixpkgs/issues/calibre-build-failure
      # calibre
    ];
  };
}
