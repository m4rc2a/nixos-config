# AGENTS.md

## Key Commands

```bash
nixos-rebuild build --flake .#<hostname>       # dry-run build
nix flake check                                 # validate flake
nix flake show                                  # list nixosConfigurations
```

Remote deploy:
```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<host>
nix run github:numtide/nixos-anywhere -- --flake .#<hostname> root@<host>  # fresh install
```

## Architecture

Two-repo split — **this repo is host configs only**:
- `nixos-profiles` (Codeberg, flake input) — all shared modules, services, profiles. Zero external inputs.
- **This repo** — hardware configs, profile assignment, machine-specific overrides.

Work hosts (wsl, rpi5-webserver) live in a **separate Arbeitgeber GitLab repo** (`git@code.arbeitgeber.com:marc.zander/nixos-config.git`).

No Snowfall Lib. All module imports are explicit via `inputs.nixos-profiles.nixosProfiles.<profile>`.

## Hosts

| Host | System | Profile | Notes |
|------|--------|---------|-------|
| `roo6` | `aarch64-linux` | server | Radxa Orion O6. User `marc` with SSH key. Overrides bootloader to GRUB (profiles default to systemd-boot). Has `network-interfaces.nix` for zone-based firewall. |
| `marc-laptop` | `x86_64-linux` | laptop | Heads BIOS — boots via kexec, no traditional bootloader. LUKS-encrypted root. Uses ext4 `/boot` (not vfat/EFI). |

## Custom Options

All custom options use `custom.` prefix. Key ones an agent will encounter:

- `custom.users.main.create` / `custom.users.main.name` / `custom.users.main.groups` — user creation
- `custom.firewall.zoneInterfaces` / `custom.firewall.exposedByZone` — zone-based firewall (server only)
- `custom.services.ports.<name>.tcp/udp` — port registry, populated by service modules in nixos-profiles
- `custom.home-manager.users.<name>` — list of hm-chammy modules to apply per user
- `custom.security.apparmor.enable` / `.mode`
- `custom.tools.yazi.flavors` — attrset of flake inputs for yazi theme flavors

## Conventions

- Home-manager is integrated via NixOS module (`inputs.home-manager.nixosModules.home-manager`), not standalone.
- Home-manager modules come from `hm-chammy` flake input, not the `./home-manager` submodule (removed in recent refactor).
- Each host's `default.nix` imports the profile, disko, home-manager, and local hardware files.
- `disk-config.nix` uses disko; device paths must be verified on target hardware (`lsblk -f`).
- Service firewall exposure is declarative: add service name to `custom.firewall.exposedByZone.<zone>` in host config, not via `networking.firewall` directly.

## Gotchas

- **Bootloader override**: `roo6` must explicitly disable `systemd-boot` and enable GRUB because aarch64 doesn't support systemd-boot. If adding a new aarch64 host, do the same.
- **Heads BIOS (marc-laptop)**: No EFI boot. `/boot` is ext4, kernel/initrd/cmdline are exported to `/boot/kexec/` via activation scripts. Don't add bootloader config to this host.
- **`custom.users.main.create = true`** on roo6 means user `marc` is created with SSH key. Home-manager runs for both `marc` and `root`.
- **No submodule anymore**: The `./home-manager` git submodule referenced in older docs has been replaced by the `hm-chammy` flake input.
