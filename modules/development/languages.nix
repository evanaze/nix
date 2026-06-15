let
  module = # aspects/development/languages.nix - Programming languages
{
  pkgs,
  username,
  ...
}: {
  # Home-manager language packages
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      cargo
      go
      hugo
      python3
    ];
  };
};
in {
  flake.modules.nixos = {
    developmentLanguages = module;
    development = module;
  };
}
