# aspects/core/default.nix - Core system configuration aggregator
{pkgs, ...}: {
  imports = [
    ./bootloader.nix
    ./locale.nix
    ./maintenance.nix
    ./networking.nix
    ./nix.nix
    ./sops.nix
    ./ssh.nix
    ./tailscale.nix
    ./user.nix
  ];

  environment.systemPackages = with pkgs; [
    cachix
    cron
    devenv
    dig
    expect
    git
    htop
    lsof
    meslo-lgs-nf
    nmap
    nixos-anywhere
    tree
    unzip
    wget
  ];
}
