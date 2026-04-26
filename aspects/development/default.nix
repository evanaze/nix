# aspects/development/default.nix - Development configuration aggregator
{pkgs, ...}: {
  imports = [
    ./direnv.nix
    ./docker.nix
    ./editors.nix
    ./git.nix
    ./languages.nix
    ./zsh.nix
  ];

  environment.systemPackages = with pkgs; [
    bun
  ];
}
