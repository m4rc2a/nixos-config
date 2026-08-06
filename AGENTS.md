# AGENTS.md

## Key Commands

```bash
nixos-rebuild build --flake .#<hostname>       # dry-run build
nix flake check                                 # validate flake
nix flake show                                  # list nixosConfigurations
```

Remote deploy (deploy-rs):
```bash
nix run .#deploy-rs -- .#<node>                # deploy a node (all its profiles)
nix run .#deploy-rs -- .#<node>.<profile>      # deploy a single profile
nix run .#deploy-rs -- --groups <group>        # deploy by group tag (servers/laptops/desktops/all)
nix run .#deploy-rs -- --dry-run .             # dry-run everything
```

Fresh install:
```bash
nix run github:numtide/nixos-anywhere -- --flake .#<hostname> root@<host>
```

## Architecture

Two-repo split — **this repo is host configs only**:
- `hm-config` (Codeberg, flake input) — shared home-manager modules/profiles.
- **This repo** — hardware configs, profile assignment, machine-specific overrides, local `systems/` + `modules/`.

No Snowfall Lib. All module imports are explicit.

## Hosts

| Host | System | Profile | Notes |
|------|--------|---------|-------|
| `roo6` | `aarch64-linux` | server | Radxa Orion O6. User `marc` with SSH key. Uses systemd-boot (aarch64 supported since systemd v253). `network-interfaces.nix` for MAC-based interface naming. |
| `marc-laptop` | `x86_64-linux` | laptop | Heads BIOS — boots via kexec, no traditional bootloader. LUKS-encrypted root. Uses ext4 `/boot` (not vfat/EFI). |
| `marc-desktop` | `x86_64-linux` | gaming-pc | Desktop-PC. Uses systemd-boot. Home-manager via `hm-config` `hosts/desktop-pc.nix`. |

## Custom Options

All custom options use `custom.` prefix. Key ones an agent will encounter:

- `custom.users.main.create` / `custom.users.main.name` / `custom.users.main.groups` — user creation

- `custom.home-manager.users.<name>` — list of hm-config modules to apply per user
- `custom.security.apparmor.enable` / `.mode`
- `custom.tools.yazi.flavors` — attrset of flake inputs for yazi theme flavors

## Conventions

- Home-manager is integrated via NixOS module (`inputs.home-manager.nixosModules.home-manager`), not standalone.
- Home-manager modules come from `hm-config` flake input, not the `./home-manager` submodule (removed in recent refactor).
- Each host's `default.nix` imports the profile, disko, home-manager, and local hardware files.
- `disk-config.nix` uses disko; device paths must be verified on target hardware (`lsblk -f`).
- Firewall is configured via `services.<name>.openFirewall = true` or `networking.firewall.allowedTCPPorts` directly in service modules.

## Gotchas

- **Bootloader (roo6)**: Uses systemd-boot — aarch64 supports it since systemd v253. Do NOT add GRUB for aarch64 hosts.
- **Heads BIOS (marc-laptop)**: No EFI boot. `/boot` is ext4, kernel/initrd/cmdline are exported to `/boot/kexec/` via activation scripts. Don't add bootloader config to this host.
- **`custom.users.main.create = true`** on roo6 means user `marc` is created with SSH key. Home-manager runs for both `marc` and `root`.
- **No submodule anymore**: The `./home-manager` git submodule referenced in older docs has been replaced by the `hm-config` flake input.
- **Deploy-rs is in `flake.nix`**: `deploy.nodes` defines nodes/profiles/groups. `sshUser = "marc"`, `interactiveSudo = true` (you type the sudo password). Group filtering is via `deploy --groups <tag>`, NOT `.#<group>` fragments.
- **home-manager NixOS module does NOT forward `nixosSystem.specialArgs` to per-user HM modules**: set `home-manager.extraSpecialArgs = { nixos_secrets = inputs.nixos-secrets; }` when a user's HM config references `nixos_secrets` (e.g. `marc-desktop`).
- **Standalone hmConfigurations in flake.nix** need `home.username`/`home.homeDirectory`/`allowUnfree`/sharedModules explicitly, mirroring what the NixOS host sets.
