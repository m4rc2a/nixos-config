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

This is a flake-based NixOS configuration using a host/profile pattern.

### Directory Structure

- `flake.nix` - Main flake using `mkHost` function to generate configurations
- `hosts/<name>/` - Per-host configuration:
  - `host.nix` - Metadata: `{ hostName, profile, system }`
  - `base.nix` - Host-specific imports and stateVersion
  - `hardware-configuration.nix` - Generated hardware config
- `profiles/<name>.nix` - Profile definitions importing modules/services
- `modules/` - Reusable NixOS modules (boot, networking, firewall, users, etc.)
- `services/` - Service configurations with custom port options
- `tools/` - CLI tool configurations (helix, yazi, git)

### Host/Profile Pattern

Each host specifies its profile in `host.nix`. The flake constructs the configuration by:
1. Reading host metadata (`host.nix`)
2. Loading `base.nix` (hardware config + host-specific settings)
3. Loading the profile (`profiles/<profile>.nix`)

### Current Hosts

- `roo6` - aarch64-linux server (profile: server)
- `wsl` - x86_64-linux WSL instance (profile: wsl)

### Zone-Based Firewall System

The server profile uses a zone-based firewall:

1. **Port Definitions** (`modules/service-ports.nix`): Services register ports via `custom.services.ports.<service>.tcp/udp`

2. **Zone Mapping** (`profiles/server/exposed-*.nix`): `exposedByZone.<zone>` lists which services are exposed per zone

3. **Interface Mapping** (`hosts/<name>/network-interfaces.nix`): `custom.firewall.zoneInterfaces` maps zones to interfaces

4. **Firewall Module** (`modules/firewall.nix`): Aggregates all mappings to configure `networking.firewall.interfaces`

When adding a new service:
1. Create the service module with `custom.services.<name>.port` options
2. Register ports: `custom.services.ports.<name>.tcp = [cfg.port]`
3. Add to zone exposure lists in `exposed-lan.nix` / `exposed-wan.nix`

### Editor Setup

Helix is configured system-wide with:
- Formatter: alejandra (Nix)
- LSP: nil (Nix)
- Config at `/etc/helix/config.toml`

### Legacy Configuration

`nixos-laptop-heads/` is a separate laptop configuration using home-manager and disko, not integrated with the main flake.
