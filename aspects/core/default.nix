# aspects/core/default.nix - Core system configuration aggregator
{...}: {
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
}
