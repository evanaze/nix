# aspects/development/default.nix - Development configuration aggregator
{...}: {
  imports = [
    ./direnv.nix
    ./docker.nix
    ./editors.nix
    ./git.nix
    ./languages.nix
  ];
}
