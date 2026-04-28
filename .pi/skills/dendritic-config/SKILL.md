---
name: dendritic-config
description: Step-by-step instructions for working inside this NixOS dendritic configuration repo. Use when planning or applying repo-specific conventions, aspect mappings, or deployment commands.
license: MIT
compatibility: NixOS flake-based config, requires access to nix command and sops keys for secrets.
metadata:
  primary-hosts: earth,mars,jupiter,rpi
  username: evanaze
---

# Dendritic Configuration Skill

Use this skill whenever you need a refresher on the repo structure, aspect mappings, or common workflows for this dendritic NixOS/home-manager configuration.

## Repository Structure Overview

- `flake.nix` / `flake.lock`: define flake inputs, hosts, and aspect imports
- `lib/`: helper functions (`mkHost.nix`, `default.nix`) exposing `_module.args`
- `aspects/`: **aspect-oriented configs** combining NixOS + home-manager per feature
  - `core/`, `shell/`, `desktop/`, `development/`, `gaming/`, `media/`, `ai/`, `monitoring/`, `networking/`, `hardware/`, etc.
  - Each aspect file provides both system-level options and `home-manager.users.${username}` config
- `hosts/<host>/`: host-specific overrides only
- `pkgs/`: custom package definitions
- `secrets/`: sops-nix encrypted secrets
- `CLAUDE.md`: project instructions auto-loaded by coding agents

## Host Aspect Matrix

| Host    | Aspects |
|---------|---------|
| earth   | core, shell, desktop, development, gaming, media, ai, monitoring, hardware/nvidia |
| mars    | core, shell, desktop, development, gaming, hardware/framework |
| jupiter | core, shell, development |
| rpi     | core/rpi, shell, networking/blocky, hardware/raspberry-pi |

## Common Tasks

### Rebuild / Deploy

```bash
# Test build for specific host
nixos-rebuild build --flake .#<hostname>

# Deploy to current host
sudo nixos-rebuild switch --flake .#<hostname>

# Build via nix directly
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

### Update Inputs

```bash
nix flake update              # update all inputs
nix flake update nixpkgs      # update specific input (e.g., nixpkgs, nixvim, home-manager)
nix flake check               # validate flake
```

### Common Aliases (defined in zsh aspect)

- `econf`: `cd ~/.config/nix && nvim` (open repo quickly)
- `update`: update flake inputs + commit
- `updnvim`: update only nixvim input
- `npush`: commit + push from config repo
- `rebuild`: host-specific rebuild shortcut

### Secrets Handling

- Edit secrets with `sops secrets/secrets.yaml` (requires age key)
- sops config in `secrets/.sops.yaml`
- Example secret references: `config.sops.secrets.openrouter-api-key`

### Aspect Authoring Pattern

Each aspect file signature: `{ pkgs, username, hostname, ... }: { ... }`

Include both:

```nix
# NixOS options
programs.zsh.enable = true;

# Home-manager user config
home-manager.users.${username} = {
  programs.zsh.enable = true;
};
```

Use `_module.args` in `lib/mkHost.nix` to pass shared values (username = "evanaze"). Avoid `specialArgs`.

### Adding New Aspect

1. Create file under `aspects/<category>/<name>.nix`
2. Add to category `default.nix`
3. Include in desired host inside `flake.nix` host definition
4. Rebuild/test

### pi Coding Agent Usage Notes

- Primary context file: `CLAUDE.md`
- Additional project skill stored here at `.pi/skills/dendritic-config`
- When using pi, run within repo root so CLAUDE.md + this skill load automatically
- Store new learnings or repo-specific workflows under `.pi/skills/` or `.pi/AGENTS.md`

## Troubleshooting Checklist

1. Run `nix flake check` for validation failures
2. Ensure secrets are decrypted locally via `sops` before rebuilds
3. Confirm correct host aspects in `flake.nix`
4. For Raspberry Pi builds, ensure cross inputs from `nixos-raspberrypi`
5. Review `aspects/core/nix.nix` for global Nix settings (unfree, flakes, etc.)

## References

- Project instructions: `CLAUDE.md`
- Pi docs: `/nix/store/.../pi-monorepo/README.md`
- Agent skill spec: https://agentskills.io/specification
