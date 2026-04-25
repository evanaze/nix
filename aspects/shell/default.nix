# aspects/shell/default.nix - Shell configuration aggregator
{pkgs, ...}: {
  imports = [
    ./zsh.nix
  ];

  environment.systemPackages = with pkgs; [
    bat
    eza
    jq
    yq
  ];
}
