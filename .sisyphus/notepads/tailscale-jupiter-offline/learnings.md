# Tailscale/Jupiter offline investigation learnings

- `services.tailscale` is enabled globally via `modules/core/tailscale.nix` for all hosts that include `core`, including `jupiter`.
- `jupiter` uses a shared auth key at `/run/secrets/ts-server-key` via `sops.secrets.ts-server-key` in the same module.
- `services.tailscale.extraSetFlags` is set in `core/tailscale.nix` to `--ssh` and `--exit-node=`.
- `services/tailscale.extraSetFlags` is additionally set in `modules/services/default.nix` to `--advertise-exit-node` and `--accept-dns=false`.
- The flake also sets `services.tailscale.openFirewall = true`.
- The common NixOS issue pattern for offline after restart/redeploy is the `tailscaled-autoconnect` service only triggering on `NeedsLogin`/`NeedsMachineAuth`, not `Stopped`.
- The repo secrets file does contain `ts-server-key` (encrypted) and confirms key material is expected to be present.
