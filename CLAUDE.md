# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS/nix-darwin flake configuration managing multiple systems:
- **desktop** (father): x86_64-linux desktop with NVIDIA GPU, gaming, AI services, and seedbox
- **framework** (fw): x86_64-linux Framework 13 laptop with AMD 7040 CPU
- **rpi**: aarch64-linux Raspberry Pi 5 server
- **mac** (cooper): x86_64-darwin macOS system

The configuration uses flakes with home-manager for user configuration management, sops-nix for secrets, and includes a custom nixvim configuration.

## Build and Deployment Commands

### Building Configurations
```bash
# Build a specific system configuration
nix build .#nixosConfigurations.desktop.config.system.build.toplevel
nix build .#nixosConfigurations.framework.config.system.build.toplevel
nix build .#nixosConfigurations.rpi.config.system.build.toplevel
nix build .#darwinConfigurations.cooper.system

# Test build without deploying
nixos-rebuild build --flake .#desktop
nixos-rebuild build --flake .#framework
```

### Deploying Changes
```bash
# Deploy to current system (NixOS)
sudo nixos-rebuild switch --flake .#desktop
sudo nixos-rebuild switch --flake .#framework

# Deploy to macOS
darwin-rebuild switch --flake .#cooper

# Test configuration without making it default
sudo nixos-rebuild test --flake .#desktop
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

### Useful Aliases (from zsh.nix)
- `econf` - Navigate to config directory and open nvim
- `update` - Update all flake inputs and commit changes
- `updnvim` - Update only nixvim input and commit
- `npush` - Commit and push changes from config directory

## Architecture

### Configuration Structure

```
.
├── flake.nix              # Main flake defining all system configurations
├── hosts/                 # Host-specific configurations
│   ├── desktop/          # Gaming/AI desktop configuration
│   │   ├── apps/         # Desktop-specific services
│   │   │   ├── ai/       # AI stack (Ollama, Open WebUI, Aider)
│   │   │   ├── default.nix
│   │   │   └── prometheus.nix
│   │   └── nvidia.nix    # NVIDIA GPU configuration
│   ├── framework/        # Framework laptop configuration
│   │   ├── sleep.nix     # Power management for battery optimization
│   │   └── gnome-keyring-unlock.nix
│   ├── rpi/              # Raspberry Pi server configuration
│   │   ├── apps/         # RPi services (blocky, webserver, gh-actions)
│   │   ├── networking.nix
│   │   └── users.nix
│   └── shared/           # Shared configurations across hosts
│       ├── default.nix   # Common packages and settings
│       ├── nixos/        # NixOS-specific shared config
│       │   ├── default.nix      # Auto-upgrade, GC
│       │   ├── zsh.nix          # Zsh configuration with aliases
│       │   └── seedbox/         # Jellyfin + torrent server (shared)
│       └── pc/           # Desktop/laptop shared config
│           ├── default.nix      # GNOME, networking
│           ├── games.nix        # Gaming packages
│           ├── gnome-keyring.nix
│           └── ipfs.nix
├── home/                 # home-manager configurations per host
│   ├── desktop.nix
│   ├── framework.nix
│   ├── mac.nix
│   ├── rpi.nix
│   ├── shared.nix        # Shared home-manager config (git, direnv, ghostty)
│   └── shared/
│       └── zsh.nix       # User-level zsh config
├── modules/              # Reusable NixOS/home-manager modules
│   └── slippi.nix        # Super Smash Bros Melee gaming setup
├── pkgs/                 # Custom package definitions
│   └── air.nix           # Air live reload tool
├── secrets.yaml          # sops-encrypted secrets
└── .sops.yaml           # sops configuration with age key
```

### Key Configuration Patterns

**Layered Configuration Model:**
1. `flake.nix` defines systems and imports host configs
2. Host configs (e.g., `hosts/desktop/default.nix`) import:
   - Hardware-specific settings
   - Shared base configurations from `hosts/shared/`
   - Host-specific apps/services
3. home-manager configs layer user-level settings similarly

**Secrets Management:**
- Uses sops-nix with age encryption
- Age key location: `~/.config/sops/age/keys.txt`
- Secrets file: `secrets.yaml`
- Configuration: `.sops.yaml`

**External Dependencies:**
- Custom nixvim configuration: `github:evanaze/nixvim-conf`
- Hardware optimizations via nixos-hardware (Framework 13 7040 AMD, RPi 5)

### Host-Specific Features

**Desktop (father):**
- NVIDIA GPU support
- Steam gaming
- Self-hosted services: Ollama, Open WebUI, Aider (AI stack)
- Seedbox: Jellyfin media server + torrent server
- Prometheus monitoring
- Passwordless sudo
- Latest kernel

**Framework (fw):**
- Framework-specific hardware optimizations (kmod, audio enhancement)
- Battery optimization via sleep.nix (disables WiFi/Bluetooth during suspend)
- GNOME keyring auto-unlock on login
- Power management tools (gnome-power-manager, powertop)
- AMD GPU configuration (amdgpu.abmlevel=0)

**Raspberry Pi (rpi):**
- ARM64 architecture
- Hardware profile from nixos-hardware
- Tailscale for remote access
- Self-hosted services: Blocky DNS, webserver, GitHub Actions runner

### Common Patterns

**System Packages:** Defined in `hosts/shared/default.nix` (git, htop, devenv, etc.)

**PC Packages:** Desktop apps in `hosts/shared/pc/default.nix` (Claude Code, Cursor, Chrome, Bitwarden, etc.)

**Gaming:** Defined in `hosts/shared/pc/games.nix` (Steam, Slippi for Super Smash Bros Melee)

**GNOME Desktop:** Configured in `hosts/shared/pc/default.nix` with autologin workaround

**Seedbox (Shared):** Media server (Jellyfin) and torrent server moved to `hosts/shared/nixos/seedbox/` for reuse across desktop and framework

**Automatic Maintenance:**
- Garbage collection: Weekly on Mondays, deletes >7 days old
- Auto-upgrade: Daily with automatic reboot (NixOS systems)
- Defined in `hosts/shared/nixos/default.nix`

## Development Workflow

### Making Configuration Changes

1. Edit relevant `.nix` files in appropriate directory
2. Test build: `nixos-rebuild build --flake .#<hostname>`
3. If successful, deploy: `sudo nixos-rebuild switch --flake .#<hostname>`
4. Commit changes with descriptive message

### Adding New Packages

**System-wide:** Add to `environment.systemPackages` in:
- `hosts/shared/default.nix` (all systems)
- `hosts/shared/pc/default.nix` (desktop/laptop)
- Host-specific `default.nix` (single system)

**User-level:** Add to `home.packages` in:
- `home/shared.nix` (all users)
- Host-specific home config (single user)

### Creating New Modules

**Reusable modules:** Place in `modules/` directory for truly generic, cross-platform modules

**Custom packages:** Place in `pkgs/` directory for custom package definitions

**NixOS-specific shared config:** Place in `hosts/shared/nixos/` for system-level NixOS configs (zsh, services)

**PC-specific shared config:** Place in `hosts/shared/pc/` for desktop/laptop configs (GNOME, games)

Import modules in `flake.nix` or host configs as needed.

### Working with Secrets

```bash
# Edit secrets (requires age key)
sops secrets.yaml

# Update sops configuration
# Edit .sops.yaml to add new paths or keys
```

## Important Notes

- Username is hardcoded as "evanaze" in `flake.nix:38`
- Editor is set to nvim globally via `hosts/shared/default.nix`
- All systems use zsh as default shell
- Flakes and nix-command are enabled on all systems
- Unfree packages are allowed globally
- Desktop uses systemd-boot, not GRUB
- Time zone: America/Denver (all systems)
- Tailscale enabled on all systems for VPN access
