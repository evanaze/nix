# aspects/shell/default.nix - Shell configuration aggregator
{...}: {
  imports = [
    ./packages.nix
    ./zsh.nix
  ];
}
