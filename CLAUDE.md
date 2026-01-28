# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake configuration using the **dendritic pattern** - an aspect-oriented architecture where each `.nix` file provides config for the same feature across NixOS and home-manager.

**Managed systems:**
- **earth**: x86_64-linux desktop with NVIDIA GPU, gaming, AI services
- **mars**: x86_64-linux Framework 13 laptop with AMD 7040 CPU
- **jupiter**: x86_64-linux server
- **rpi** (mercury): aarch64-linux Raspberry Pi 5 server

The configuration uses flake-parts, home-manager for user configuration, sops-nix for secrets, and includes a custom nixvim configuration.

## Build and Deployment Commands

### Building Configurations
```bash
# Build a specific system configuration
nix build .#nixosConfigurations.earth.config.system.build.toplevel
nix build .#nixosConfigurations.mars.config.system.build.toplevel
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel
nix build .#nixosConfigurations.rpi.config.system.build.toplevel

# Test build without deploying
nixos-rebuild build --flake .#earth
nixos-rebuild build --flake .#mars
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

### Useful Aliases (from zsh aspect)
- `econf` - Navigate to config directory and open nvim
- `update` - Update all flake inputs and commit changes
- `updnvim` - Update only nixvim input and commit
- `npush` - Commit and push changes from config directory
- `rebuild` - Rebuild current system (host-specific)

## Architecture

### Dendritic Configuration Structure

```
.
├── flake.nix                    # Minimal: inputs + flake-parts + host definitions
├── lib/
│   ├── default.nix              # Library entry point
│   └── mkHost.nix               # Host builder function
├── aspects/                     # Feature-oriented modules (NixOS + home-manager combined)
│   ├── core/
│   │   ├── default.nix          # Aggregator
│   │   ├── bootloader.nix       # systemd-boot
│   │   ├── locale.nix           # Timezone, i18n
│   │   ├── maintenance.nix      # Auto-upgrade, GC
│   │   ├── networking.nix       # NetworkManager
│   │   ├── nix.nix              # Flakes, unfree, experimental
│   │   ├── packages.nix         # CLI tools
│   │   ├── rpi.nix              # Core for Raspberry Pi (no bootloader/networking)
│   │   ├── sops.nix             # Secrets management
│   │   ├── ssh.nix              # OpenSSH
│   │   ├── tailscale.nix        # VPN service
│   │   └── user.nix             # User account
│   ├── shell/
│   │   ├── default.nix
│   │   ├── packages.nix         # Shell utilities
│   │   └── zsh.nix              # System + home-manager zsh combined
│   ├── desktop/
│   │   ├── default.nix
│   │   ├── apps.nix             # Desktop applications
│   │   ├── fonts.nix
│   │   ├── gnome.nix            # GNOME + GDM
│   │   ├── printing.nix         # CUPS
│   │   ├── sound.nix            # PipeWire
│   │   └── xserver.nix          # X11
│   ├── development/
│   │   ├── default.nix
│   │   ├── direnv.nix
│   │   ├── docker.nix
│   │   ├── editors.nix          # nixvim, ghostty, zellij
│   │   ├── git.nix              # System + home-manager git
│   │   └── languages.nix        # Programming languages
│   ├── gaming/
│   │   ├── default.nix
│   │   ├── slippi.nix           # Super Smash Bros Melee
│   │   └── steam.nix
│   ├── media/
│   │   ├── default.nix
│   │   ├── ipfs.nix             # Kubo IPFS node
│   │   └── jellyfin.nix         # Media server
│   ├── ai/
│   │   ├── default.nix
│   │   ├── aider.nix            # AI coding assistant
│   │   └── ollama.nix           # CUDA-aware LLM server
│   ├── monitoring/
│   │   ├── default.nix
│   │   ├── grafana.nix
│   │   └── prometheus.nix
│   ├── networking/
│   │   ├── default.nix
│   │   ├── blocky.nix           # DNS ad-blocking
│   │   └── networkmanager.nix
│   └── hardware/
│       ├── default.nix
│       ├── framework.nix        # Framework + power management
│       ├── nvidia.nix           # NVIDIA GPU
│       └── raspberry-pi.nix     # RPi 5 configuration
├── hosts/                       # Host-specific overrides only
│   ├── earth/
│   │   ├── default.nix          # Host-specific config + overrides
│   │   └── hardware-configuration.nix
│   ├── mars/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── jupiter/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── rpi/
│       ├── default.nix
│       ├── disko-nvme-zfs.nix
│       ├── hardware-configuration.nix
│       └── pi5-configtxt.nix
├── pkgs/                        # Custom package definitions
│   └── air.nix
└── secrets/
    ├── secrets.yaml             # sops-encrypted secrets
    └── .sops.yaml               # sops configuration
```

### Key Architecture Principles

1. **Aspect-oriented**: Files organized by feature, not host
2. **Combined configs**: Each aspect file contains both NixOS and home-manager config
3. **Host composition**: Hosts select which aspects to apply
4. **No specialArgs**: Uses `_module.args` for shared values (username, inputs, hostname)
5. **flake-parts** as foundation

### Host-to-Aspect Mapping

| Host    | Aspects |
|---------|---------|
| earth   | core, shell, desktop, development, gaming, media, ai, monitoring, hardware/nvidia |
| mars    | core, shell, desktop, development, gaming, hardware/framework |
| jupiter | core, shell, development |
| rpi     | core/rpi, shell, networking/blocky, hardware/raspberry-pi |

### Aspect Pattern Example

Each aspect file follows this structure:

```nix
# aspects/shell/zsh.nix
{pkgs, username, hostname, ...}: {
  # NixOS System Configuration
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [fzf ripgrep zoxide];

  # Home-Manager Configuration
  home-manager.users.${username} = {
    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nix#${hostname}";
      };
    };
  };
}
```

## Development Workflow

### Making Configuration Changes

1. Identify which aspect the change belongs to
2. Edit the relevant aspect file in `aspects/`
3. For host-specific overrides, edit `hosts/<hostname>/default.nix`
4. Test build: `nixos-rebuild build --flake .#<hostname>`
5. If successful, deploy: `sudo nixos-rebuild switch --flake .#<hostname>`

### Adding New Packages

**System-wide (all hosts):** Add to `aspects/core/packages.nix`

**Desktop/laptop:** Add to `aspects/desktop/apps.nix`

**Development tools:** Add to `aspects/development/` (appropriate file)

**Host-specific:** Add to `hosts/<hostname>/default.nix`

### Creating New Aspects

1. Create a new `.nix` file in the appropriate category under `aspects/`
2. Follow the aspect pattern (system config + home-manager config)
3. Import in the category's `default.nix` aggregator
4. Add to host aspect lists in `flake.nix` as needed

### Working with Secrets

```bash
# Edit secrets (requires age key)
sops secrets/secrets.yaml

# Update sops configuration
# Edit secrets/.sops.yaml to add new paths or keys
```

## Important Notes

- Username is hardcoded as "evanaze" in `lib/default.nix`
- `hostname` variable is passed to all modules and available for host-specific logic
- Editor is set to nvim globally via `aspects/core/nix.nix`
- All systems use zsh as default shell
- Flakes and nix-command are enabled on all systems
- Unfree packages are allowed globally
- Desktop/laptop systems use systemd-boot
- Time zone: America/Denver (all systems)
- Tailscale enabled on all systems for VPN access

### External Dependencies

- **flake-parts**: Flake structure management
- **nixvim**: Custom neovim configuration (`github:evanaze/nixvim-conf`)
- **nixos-hardware**: Hardware optimizations (Framework 13 7040 AMD, RPi 5)
- **nixos-raspberrypi**: Raspberry Pi 5 support
- **slippi**: Super Smash Bros Melee netplay
- **sops-nix**: Secrets management with age encryption
- **disko**: Declarative disk partitioning (RPI, Jupiter)
