# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake configuration using the **dendritic pattern**. Public feature composition is exposed through flake-parts modules under `modules/`, primarily via `flake.modules.nixos.<name>`.

**Managed systems:**
- **earth**: x86_64-linux desktop with NVIDIA GPU, gaming, AI services
- **mars**: x86_64-linux Framework 13 laptop with AMD 7040 CPU
- **jupiter**: x86_64-linux server

The configuration uses flake-parts, import-tree, home-manager, sops-nix, and a custom nixvim configuration.

## Build and Deployment Commands

> **Check hostname first** with `hostname` to confirm which machine you're on. If you're on the target host, run the deploy command directly instead of asking the user to do it.

### Building Configurations
```bash
# Build a specific system configuration
nix build .#nixosConfigurations.earth.config.system.build.toplevel
nix build .#nixosConfigurations.mars.config.system.build.toplevel
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel

# Test build without deploying
nixos-rebuild build --flake .#earth
nixos-rebuild build --flake .#mars
nixos-rebuild build --flake .#jupiter
```

### Deploying Changes
```bash
# Deploy to current system (NixOS)
sudo nixos-rebuild switch --flake .#earth
sudo nixos-rebuild switch --flake .#mars
sudo nixos-rebuild switch --flake .#jupiter

# Test configuration without making it default
sudo nixos-rebuild test --flake .#earth
```

### Updating Dependencies
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
nix flake update nixvim
nix flake update home-manager

# Check flake for errors
nix flake check
```

### Useful Aliases
- `econf` - Navigate to config directory and open nvim
- `update` - Update all flake inputs and commit changes
- `updnvim` - Update only nixvim input and commit
- `npush` - Commit and push changes from config directory
- `rebuild` - Rebuild current system (host-specific)

## Architecture

### Dendritic Structure

```
.
├── flake.nix                    # Minimal: inputs + flake-parts + import-tree
├── modules/                     # Auto-imported flake-parts modules
│   ├── hosts.nix                # nixosConfigurations and host composition
│   ├── nixos.nix                # Public flake.modules.nixos feature names
│   ├── packages.nix             # perSystem packages
│   ├── systems.nix              # Supported systems
│   └── _legacy/                 # Ignored by import-tree; direct NixOS/HM modules
├── pkgs/                        # Custom package definitions
└── secrets/                     # sops-encrypted secrets
```

`import-tree ./modules` loads flake-parts modules recursively. Paths containing `/_` are ignored, so `modules/_legacy` contains direct NixOS/Home Manager modules that are imported only through public `flake.modules.nixos` definitions.

### Key Principles

1. **Feature-oriented modules**: Hosts compose named features, not raw file paths.
2. **Simple flake**: `flake.nix` is a dependency manifest and entrypoint only.
3. **Public module interface**: Add host-consumable NixOS modules in `modules/nixos.nix` as `flake.modules.nixos.<name>`.
4. **Host composition lives outside flake.nix**: Edit `modules/hosts.nix` for host lists and state versions.
5. **No standalone mkHost library**: Any host helper stays local to `modules/hosts.nix`.

### Host Composition

| Host    | Main modules |
|---------|--------------|
| earth   | core, desktop, development, gaming, aiServer, monitoring, NVIDIA/hardware |
| mars    | core, desktop, development, steam, monitoring, Framework/hardware |
| jupiter | core, development, backup, business, media, monitoring, networking, services |

## Development Workflow

### Making Configuration Changes

1. Identify which feature module the change belongs to.
2. Edit the relevant direct module under `modules/_legacy/`.
3. If the feature needs a public name for host composition, add it to `modules/nixos.nix`.
4. If host composition changes, edit `modules/hosts.nix`.
5. Test build: `nixos-rebuild build --flake .#<hostname>`.
6. If successful, deploy: `sudo nixos-rebuild switch --flake .#<hostname>`.

### Adding New Packages

**Flake packages:** Add to `modules/packages.nix`.

**System-wide packages:** Add to the relevant module under `modules/_legacy/core/` or another feature directory.

**Desktop/laptop packages:** Add to `modules/_legacy/desktop/`.

**Development tools:** Add to `modules/_legacy/development/`.

### Creating New Modules

1. Create the direct NixOS/Home Manager implementation under `modules/_legacy/<category>/<name>.nix`.
2. Expose it from `modules/nixos.nix` as `flake.modules.nixos.<name>`.
3. Add that public module name to the relevant host in `modules/hosts.nix`.
4. Run `nix flake show` and build affected hosts.

### Working with Secrets

```bash
# Edit secrets (requires age key)
sops secrets/secrets.yaml

# Update sops configuration
# Edit secrets/.sops.yaml to add new paths or keys
```

## Important Notes

- Username is currently set to `evanaze` in `modules/hosts.nix`.
- `hostname`, `username`, `inputs`, and `system` are still passed through `_module.args` for legacy modules.
- Editor is set to nvim globally via `modules/_legacy/core/nix.nix`.
- All systems use zsh as default shell.
- Flakes and nix-command are enabled on all systems.
- Unfree packages are allowed globally.
- Desktop/laptop systems use systemd-boot.
- Time zone: America/Denver.
- Tailscale is enabled on all systems for VPN access.

### External Dependencies

- **flake-parts**: Flake structure management
- **import-tree**: Recursive loading of flake-parts modules under `modules/`
- **nixvim**: Neovim configuration framework, config stored under `modules/_legacy/development/nixvim/`
- **nixos-hardware**: Hardware optimizations
- **slippi**: Super Smash Bros Melee netplay
- **sops-nix**: Secrets management with age encryption
