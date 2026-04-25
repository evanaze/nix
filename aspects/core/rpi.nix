# aspects/core/rpi.nix - Core configuration for Raspberry Pi
# Minimal core that doesn't include bootloader or networking (RPI has custom)
{...}: {
  imports = [
    ./locale.nix
    ./maintenance.nix
    ./nix.nix
    ./packages.nix
    ./rpi-user.nix
    ./sops.nix
    ./tailscale.nix
    # Note: No bootloader.nix (RPI uses different bootloader)
    # Note: No networking.nix (RPI has custom networking)
    # Note: No ssh.nix (RPI has custom ssh setup)
  ];
}
