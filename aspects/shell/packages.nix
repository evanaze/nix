# aspects/shell/packages.nix - CLI tools and utilities
{pkgs, ...}: {
  # Additional shell-related system packages
  environment.systemPackages = with pkgs; [
    bat
    eza
    jq
    yq
  ];
}
