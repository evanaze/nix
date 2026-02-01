# aspects/core/default.nix - Core system configuration aggregator
{pkgs, ...}: {
  imports = [
    ./bootloader.nix
    ./locale.nix
    ./maintenance.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./tailscale.nix
    ./user.nix
  ];

  environment.systemPackages = with pkgs; [
    nixos-anywhere
  ];
}
