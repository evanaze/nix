# Tailscale/Jupiter offline investigation issues

- `nix eval .#nixosConfigurations.jupiter.config.services.tailscale --json` fails with:
  `services.tailscale.derper.domain was accessed but has no value defined`.
  This appears to be a config evaluation edge in this flake (possibly from a NixOS module default/override path) and blocks fully evaluating/printing the full merged tailscale config in one command.
- No live `jupiter` telemetry (`systemctl`, `journalctl`, `tailscale status`) is available from this environment yet.
