# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Build and switch to a configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Build without switching (dry-run)
nixos-rebuild build --flake .#<hostname>

# Check flake validity
nix flake check

# Update flake inputs
nix flake update

# View available configurations
nix flake show
```

## Architecture Overview

This is a flake-based NixOS configuration using Snowfall Lib for automatic module discovery and host management.

### Directory Structure

```
nix/
├── systems/<arch>/<hostname>/    # Per-host configuration
│   ├── default.nix               # Host entry point + feature import
│   ├── hardware-configuration.nix
│   └── disk-config.nix           # (if using disko)
├── modules/nixos/                # Reusable modules (auto-loaded)
│   ├── desktop/                  # Sway, pipewire, bluetooth...
│   ├── virtualization/           # Podman, waydroid
│   ├── gaming/                   # Steam
│   ├── development/              # nix-ld
│   ├── security/                 # doas
│   ├── tools/                    # helix, yazi, git
│   └── *.nix                     # Base modules
└── features/                     # Feature bundles (not auto-loaded)
    ├── server/                   # Server feature + services
    ├── laptop/                   # Laptop feature
    └── wsl/                      # WSL feature
```

### Snowfall Lib Conventions

- **Systems**: Hostnames are derived from directory names under `nix/systems/<arch>/`
- **Modules**: All modules in `nix/modules/nixos/` are automatically applied to ALL systems
- **Features**: Feature bundles in `nix/features/` must be explicitly imported per-host
- **Namespace**: Custom options use the `custom.` prefix

### Current Hosts

- `roo6` - aarch64-linux server (feature: server)
- `wsl` - x86_64-linux WSL instance (feature: wsl)
- `marc-laptop` - x86_64-linux laptop with Heads BIOS (feature: laptop)

### Adding a New Host

1. Create `nix/systems/<arch>/<hostname>/default.nix`
2. Add hardware config
3. Import the desired feature

### Zone-Based Firewall System (Server)

1. **Port Definitions** (`modules/nixos/service-ports.nix`): Services register ports via `custom.services.ports.<service>.tcp/udp`

2. **Zone Mapping** (`features/server/exposed-*.nix`): `exposedByZone.<zone>` lists which services are exposed per zone

3. **Interface Mapping** (`systems/<arch>/<hostname>/network-interfaces.nix`): `custom.firewall.zoneInterfaces` maps zones to interfaces

4. **Firewall Module** (`modules/nixos/firewall.nix`): Aggregates all mappings to configure `networking.firewall.interfaces`

### Adding a New Service

1. Create service module in `features/server/services/<name>.nix`
2. Register ports: `custom.services.ports.<name>.tcp = [port]`
3. Add to zone exposure lists in `exposed-lan.nix` / `exposed-wan.nix`

### Heads BIOS (marc-laptop)

The laptop uses Heads BIOS which boots via kexec without a traditional bootloader. The kernel, initrd, and cmdline are exported to `/boot/kexec/` via activation scripts.
