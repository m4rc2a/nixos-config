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

# Deploy to remote host via Colmena
nix run .#colmena apply

# Deploy a specific host
nix run .#colmena apply --on <hostname>
```

## Architecture Overview

This is a flake-based NixOS configuration split into two repos:

1. **`nixos-shared`** (Codeberg) — Shared modules, services, and profiles. Consumed as a flake input. Has zero external inputs itself.
2. **This repo** — Host-specific configs only: hardware, machine overrides, and profile assignment.

### No Snowfall Lib

Snowfall Lib has been removed. All module imports are explicit via profiles. No auto-discovery.

### Directory Structure

```
hosts/
├── roo6/
│   ├── default.nix              # Server profile + hardware + overrides
│   ├── hardware-configuration.nix
│   ├── network-interfaces.nix   # MAC addresses, zone interfaces
│   ├── storage.nix              # Btrfs mount (machine-specific)
│   └── colmena.nix
├── marc-laptop/
│   ├── default.nix              # Laptop profile + hardware + overrides
│   ├── hardware-configuration.nix
│   ├── disk-config.nix
│   └── colmena.nix
└── wsl/
    ├── default.nix              # WSL profile + hardware + overrides
    ├── hardware-configuration.nix
```

### Profiles (from nixos-shared)

Profiles are the primary mechanism for host differentiation. Each imports a specific set of shared modules:

- **Server** — Base + security (doas + apparmor) + all services + firewall
- **Laptop** — Base + desktop + virtualization + gaming + development + security
- **WSL** — Minimal base only (no security modules)

### Custom Options

All custom options use the `custom.` prefix:

| Option | Module | Description |
|--------|--------|-------------|
| `custom.users.main.name` | users | Main username (null = no user created) |
| `custom.users.main.groups` | users | Extra groups for main user |
| `custom.boot.sky1Kernel.enable` | boot | Sky1 kernel with hardware patches |
| `custom.firewall.zoneInterfaces` | firewall | Zone → interface mapping |
| `custom.firewall.exposedByZone` | firewall | Zone → service names mapping |
| `custom.security.apparmor.enable` | apparmor | Enable AppArmor |
| `custom.security.apparmor.mode` | apparmor | complain or enforce |
| `custom.tools.yazi.flavors` | yazi | Flavor theme paths (attrset) |
| `custom.services.ports.*` | service-ports | Port registry (tcp/udp per service) |
| `custom.services.<name>.port(s)` | services | Per-service port config |

### Current Hosts

| Host | Arch | Profile | User | Deployment |
|------|------|---------|------|------------|
| `roo6` | aarch64-linux | server | root | Colmena (`roo6.lan`) |
| `wsl` | x86_64-linux | wsl | wsl | Local only |
| `marc-laptop` | x86_64-linux | laptop | marc | Colmena (`marc-laptop.lan`) |

### Home Manager Integration

Home-manager configuration lives in a **git submodule** at `./home-manager`. The submodule must be initialized before building (`git submodule update --init`).

### Zone-Based Firewall System (Server)

A declarative firewall that maps services → zones → interfaces:

1. **Port Registry** (`service-ports` module): `custom.services.ports.<service>.tcp/udp`
2. **Service Ports** (service modules): Each service writes its ports to the registry
3. **Zone Exposure** (host config): `custom.firewall.exposedByZone.<zone>` lists service names
4. **Interface Mapping** (host config): `custom.firewall.zoneInterfaces` maps zones to interfaces
5. **Firewall Module**: Aggregates all mappings to generate `networking.firewall.interfaces`

### Adding a New Host

1. Create `hosts/<hostname>/default.nix`
2. Add `hardware-configuration.nix` (generate with `nixos-generate-config`)
3. Import the desired profile: `inputs.nixos-shared.nixosProfiles.<profile>`
4. Set machine-specific options (`custom.users.main.name`, etc.)
5. For Colmena: add `colmena.nix` with `deployment` options and register in `flake.nix`

### Adding a New Service (in nixos-shared)

1. Create module in `modules/services/<name>.nix`
2. Define port options under `custom.services.<name>.port(s)`
3. Register ports: `custom.services.ports.<name>.tcp = [cfg.port]`
4. Add module to the server profile's import list
5. In host config, add service name to `custom.firewall.exposedByZone.<zone>`

### Heads BIOS (marc-laptop)

The laptop uses Heads BIOS which boots via kexec without a traditional bootloader. The kernel, initrd, and cmdline are exported to `/boot/kexec/` via activation scripts.

### Colmena Deployment

Remote hosts (`roo6`, `marc-laptop`) can be deployed via Colmena. The hive is defined in `flake.nix` as `colmenaHive`. Each host has a `colmena.nix` with deployment target settings. The `marc-laptop` has `allowLocalDeployment = true`.
