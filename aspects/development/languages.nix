# aspects/development/languages.nix - Programming languages
{
  pkgs,
  username,
  ...
}: {
  # Home-manager language packages
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      calibre
      cargo
      go
      hugo
      python3
      ripgrep
    ];
  };
}
