# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Build and switch to a configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Build without switching (dry-run)
nixos-rebuild build --flake .#<hostname>

# Verify flake validity
nix flake check

# Update flake inputs
nix flake update

# View available configurations
nix flake show

# Install a host via nixos-anywhere (remote provisioning)
nix run github:numtide/nixos-anywhere -- --flake .#<hostname> root@<host>

# Deploy config changes to a running host (deploy-rs)
nix run .#deploy-rs -- .#<hostname>          # all profiles on a node
nix run .#deploy-rs -- .#<hostname>.<profile> # single profile
nix run .#deploy-rs -- --groups <group>       # group tag: servers/laptops/desktops/personal/all
nix run .#deploy-rs -- --dry-run .            # dry-run everything
```

## Architecture Overview

This is a flake-based NixOS configuration split into two repos:

1. **`hm-config`** (Codeberg) — Shared home-manager modules and profiles. Consumed as a flake input.
2. **This repo** — Private host-specific configs: hardware, machine overrides, profile assignment, and local `profiles/` + `modules/`.

Work-related hosts (wsl, rpi5-webserver) live in a separate repo on Arbeitgeber GitLab (`git@code.arbeitgeber.com:marc.zander/nixos-config.git`).

### No Snowfall Lib

Snowfall Lib has been removed. All module imports are explicit via profiles. No auto-discovery.

### Directory Structure

```
hosts/
├── roo6/
│   ├── default.nix              # Server profile + hardware + overrides
│   ├── hardware-configuration.nix
│   ├── disk-config.nix          # disko partition layout
│   └── network-interfaces.nix   # MAC addresses, zone interfaces
├── marc-laptop/
│   ├── default.nix              # Laptop profile + hardware + overrides
│   ├── hardware-configuration.nix
│   └── disk-config.nix
└── marc-desktop/
    ├── default.nix              # Gaming-PC profile + hardware + overrides
    ├── hardware-configuration.nix
    └── disk-config.nix
```

### Profiles (local)

Profiles are the primary mechanism for host differentiation. Each imports a specific set of local modules:

- **server** — Base + services + firewall
- **laptop** — Base + desktop + virtualization + gaming + development + security
- **desktop** / **gaming-pc** — Base + desktop + gaming
- **wsl** — Minimal base (no desktop, no services)

Home-manager modules come from the `hm-config` flake input.

### Custom Options

All custom options use the `custom.` prefix:

| Option | Module | Description |
|--------|--------|-------------|
| `custom.users.main.name` | users | Main username (null = no user created) |
| `custom.users.main.groups` | users | Extra groups for main user |
| `custom.boot.sky1Kernel.enable` | boot | Sky1 kernel with hardware patches |

| `custom.security.apparmor.enable` | apparmor | Enable AppArmor |
| `custom.security.apparmor.mode` | apparmor | complain or enforce |
| `custom.tools.yazi.flavors` | yazi | Flavor theme paths (attrset) |

| `custom.services.<name>.port(s)` | services | Per-service port config |

### Current Hosts

| Host | Arch | Profile | User | Hardware | Deployment |
|------|------|---------|------|----------|------------|
| `roo6` | aarch64-linux | server | root | Radxa Orion O6 | deploy-rs (`roo6`) |
| `marc-laptop` | x86_64-linux | laptop | marc | ThinkPad T440p | deploy-rs (`marc-laptop`) |
| `marc-desktop` | x86_64-linux | gaming-pc | marc | desktop-PC | deploy-rs (`marc-desktop`) |

### Firewall

Firewall is enabled via the server profile. Services open ports using:
- `services.<name>.openFirewall = true` (for services that support it)
- `networking.firewall.allowedTCPPorts` otherwise

### Home Manager Integration

Home-manager modules come from the `hm-config` flake input, not a local submodule (the `./home-manager` submodule was removed in a recent refactor). Home-manager is integrated via the NixOS module (`inputs.home-manager.nixosModules.home-manager`), not standalone.

> **Note:** The home-manager NixOS module does NOT forward `nixosSystem.specialArgs` to per-user HM modules. Set `home-manager.extraSpecialArgs = { nixos_secrets = inputs.nixos-secrets; }` when a user's HM config references `nixos_secrets` (e.g. `marc-desktop`).

### Deployment (deploy-rs)

Hosts are deployed with deploy-rs via the `deploy` flake output. Nodes, profiles, and group tags are defined in `flake.nix` under `deploy.nodes`. Uses `sshUser = "marc"` with `interactiveSudo = true` (you type the sudo password) and `magicRollback = true`.

See [docs/deploy-rs.md](docs/deploy-rs.md) for details.

### nixos-anywhere Deployment

Remote hosts can be provisioned from scratch using nixos-anywhere. Each host has a `disk-config.nix` defining its disk layout via disko. To install:

```bash
nix run github:numtide/nixos-anywhere -- --flake .#<hostname> root@<host>
```

### Adding a New Host

1. Create `hosts/<hostname>/default.nix`
2. Add `hardware-configuration.nix` (generate with `nixos-generate-config`)
3. Add `disk-config.nix` (disko partition layout for nixos-anywhere)
4. Import the desired profile (`../../profiles/<profile>.nix`)
5. Set machine-specific options (users, hostname, secrets, home-manager users)
6. Register in `flake.nix` under `nixosConfigurations`
7. If you also want to deploy it with deploy-rs, add a matching `deploy.nodes.<hostname>` entry

### Adding a New Service (in this repo)

1. Create module in `modules/services/<name>.nix`
2. Enable the service and open its firewall port via `services.<name>.openFirewall = true` or `networking.firewall.allowedTCPPorts`
3. Add module to the relevant profile's import list in `profiles/`

### Heads BIOS (marc-laptop)

The laptop uses Heads BIOS which boots via kexec without a traditional bootloader. The kernel, initrd, and cmdline are exported to `/boot/kexec/` via activation scripts.

