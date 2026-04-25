# aspects/development/default.nix - Development configuration aggregator
{...}: {
  imports = [
    ./direnv.nix
    ./docker.nix
    # ./editors.nix # Temporarily disabled due to vim plugin issues
    ./git.nix
    ./languages.nix
  ];
}
