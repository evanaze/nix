# aspects/shell/default.nix - Shell configuration aggregator
{pkgs, ...}: {
  imports = [
    ./packages.nix
    ./zsh.nix
  ];
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
}
