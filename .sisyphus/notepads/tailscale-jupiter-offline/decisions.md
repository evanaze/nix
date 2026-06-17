# Tailscale/Jupiter offline investigation decisions

- Start with control-plane diagnostics (`BackendState`, `needs-auth` states, service logs) before changing config.
- Keep focus on NixOS module/service behavior (`tailscaled`, `tailscaled-autoconnect`) rather than generic host reachability.
- Defer invasive changes until we have live `BackendState`/journal output from `jupiter`.
- Re-check auth key lifecycle (expiry, revocation) because shared auth-key workflows can silently lead to `NeedsMachineAuth`-style states.
